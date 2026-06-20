from rest_framework import status
from rest_framework.generics import ListAPIView, RetrieveAPIView, CreateAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.filters import SearchFilter
from django.db.models import Avg, Count, Q
from django.core.exceptions import PermissionDenied

from .models import Clinic, ClinicImage, ClinicReview
from .serializers import ClinicSerializer, ClinicImageSerializer, ClinicReviewSerializer
from backend.utils.permissions import IsPatient


class ClinicListView(ListAPIView):
    queryset = Clinic.objects.prefetch_related("gallery")
    serializer_class = ClinicSerializer
    permission_classes = [AllowAny]
    filter_backends = [SearchFilter]
    search_fields = ("name", "address", "city")

    def get_queryset(self):
        qs = super().get_queryset()
        qs = qs.annotate(
            _annotation_avg_rating=Avg("reviews__rating"),
            _annotation_review_count=Count("reviews"),
            _annotation_doctors_count=Count("doctors", filter=Q(doctors__is_active=True)),
        )

        lat = self.request.query_params.get("lat")
        lng = self.request.query_params.get("lng")

        ordering = self.request.query_params.get("ordering", "-avg_rating")
        descending = ordering.startswith("-")
        field = ordering.lstrip("-")
        field_map = {
            "avg_rating": "_annotation_avg_rating",
            "review_count": "_annotation_review_count",
            "doctors_count": "_annotation_doctors_count",
            "created_at": "created_at",
        }

        if lat and lng:
            try:
                user_lat = float(lat)
                user_lng = float(lng)
                qs = qs.extra(
                    select={"distance_km": f"""
                        (6371 * acos(cos(radians({user_lat})) * cos(radians(latitude)) *
                        cos(radians(longitude) - radians({user_lng})) +
                        sin(radians({user_lat})) * sin(radians(latitude))))
                    """},
                )
                if field == "distance":
                    order_field = "distance_km"
                else:
                    order_field = field_map.get(field, "_annotation_avg_rating")
                if descending:
                    order_field = "-" + order_field
                return qs.order_by(order_field, "-id")
            except (ValueError, TypeError):
                pass

        order_field = field_map.get(field, "_annotation_avg_rating")
        if descending:
            order_field = "-" + order_field
        return qs.order_by(order_field, "-id")


class ClinicDetailView(RetrieveAPIView):
    queryset = Clinic.objects.annotate(
        _annotation_avg_rating=Avg("reviews__rating"),
        _annotation_review_count=Count("reviews"),
        _annotation_doctors_count=Count("doctors", filter=Q(doctors__is_active=True)),
    ).prefetch_related("gallery")
    serializer_class = ClinicSerializer
    permission_classes = [AllowAny]


class ClinicGalleryUploadView(CreateAPIView):
    queryset = ClinicImage.objects.all()
    serializer_class = ClinicImageSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        clinic_id = self.kwargs.get("clinic_id")
        user = self.request.user
        try:
            clinic = Clinic.objects.get(pk=clinic_id)
        except Clinic.DoesNotExist:
            raise PermissionDenied("Klinika topilmadi")
        doctor = getattr(user, "doctor", None) if user.role == "doctor" else None
        if user.role != "admin" and not (doctor and doctor.clinic_id == clinic.id):
            raise PermissionDenied("Ruxsat yo'q")
        serializer.save(clinic_id=clinic_id, uploaded_by=user)


class ClinicReviewsView(ListAPIView):
    serializer_class = ClinicReviewSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        clinic_id = self.kwargs.get("clinic_id")
        return ClinicReview.objects.filter(clinic_id=clinic_id).select_related("user")


class CreateClinicReviewView(CreateAPIView):
    queryset = ClinicReview.objects.all()
    serializer_class = ClinicReviewSerializer
    permission_classes = [IsAuthenticated, IsPatient]

    def perform_create(self, serializer):
        clinic_id = self.kwargs.get("clinic_id")
        serializer.save(user=self.request.user, clinic_id=clinic_id)


class CheckClinicReviewView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, clinic_id):
        has_reviewed = ClinicReview.objects.filter(
            user=request.user, clinic_id=clinic_id
        ).exists()
        return Response({"has_reviewed": has_reviewed})


class UpdateClinicReviewView(APIView):
    permission_classes = [IsAuthenticated, IsPatient]

    def put(self, request, clinic_id):
        try:
            review = ClinicReview.objects.get(
                user=request.user, clinic_id=clinic_id
            )
        except ClinicReview.DoesNotExist:
            return Response(
                {"error": "Review not found"}, status=status.HTTP_404_NOT_FOUND
            )
        serializer = ClinicReviewSerializer(review, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class GalleryImageDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        try:
            image = ClinicImage.objects.get(pk=pk)
        except ClinicImage.DoesNotExist:
            return Response({"error": "Image not found"}, status=status.HTTP_404_NOT_FOUND)

        user = request.user
        doctor = getattr(user, "doctor", None) if user.role == "doctor" else None

        if user.role == "admin":
            pass
        elif doctor and image.clinic == doctor.clinic:
            pass
        elif image.uploaded_by == user:
            pass
        else:
            return Response({"error": "Permission denied"}, status=status.HTTP_403_FORBIDDEN)

        image.image.delete(save=False)
        image.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class ClinicAvatarUploadView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, pk):
        try:
            clinic = Clinic.objects.get(pk=pk)
        except Clinic.DoesNotExist:
            return Response({"error": "Klinika topilmadi"}, status=status.HTTP_404_NOT_FOUND)

        user = request.user
        doctor = getattr(user, "doctor", None) if user.role == "doctor" else None

        if user.role != "admin" and not (doctor and doctor.clinic_id == clinic.id):
            return Response({"error": "Ruxsat yo'q"}, status=status.HTTP_403_FORBIDDEN)

        image = request.FILES.get("image")
        if not image:
            return Response({"error": "Rasm talab qilinadi"}, status=status.HTTP_400_BAD_REQUEST)

        clinic.image = image
        clinic.save()

        serializer = ClinicSerializer(clinic)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def delete(self, request, pk):
        try:
            clinic = Clinic.objects.get(pk=pk)
        except Clinic.DoesNotExist:
            return Response({"error": "Klinika topilmadi"}, status=status.HTTP_404_NOT_FOUND)

        user = request.user
        doctor = getattr(user, "doctor", None) if user.role == "doctor" else None

        if user.role != "admin" and not (doctor and doctor.clinic_id == clinic.id):
            return Response({"error": "Ruxsat yo'q"}, status=status.HTTP_403_FORBIDDEN)

        if clinic.image:
            clinic.image.delete(save=False)
            clinic.image = None
            clinic.save()

        return Response(status=status.HTTP_204_NO_CONTENT)
