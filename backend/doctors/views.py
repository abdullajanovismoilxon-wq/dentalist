import math
import datetime
from rest_framework import status
from rest_framework.generics import ListAPIView, RetrieveAPIView, UpdateAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q, Avg, Count, F, Value, FloatField
from django.db.models.functions import ACos, Cos, Radians, Sin, Sqrt

from .models import Doctor, Specialization
from .serializers import DoctorListSerializer, DoctorDetailSerializer, DoctorProfileUpdateSerializer, SpecializationSerializer
from backend.appointments.models import Appointment
from backend.appointments.serializers import AppointmentSerializer
from backend.services.models import Service
from backend.services.serializers import ServiceSerializer
from backend.schedule.models import DoctorSchedule, TimeSlot, BlockedSlot
from backend.schedule.serializers import TimeSlotSerializer
from backend.schedule.serializers import DoctorScheduleSerializer, BlockedSlotSerializer
from backend.clinics.models import ClinicImage
from backend.clinics.serializers import ClinicImageSerializer
from backend.utils.permissions import IsDoctor


class SpecializationListView(ListAPIView):
    queryset = Specialization.objects.all()
    serializer_class = SpecializationSerializer
    permission_classes = [AllowAny]


class DoctorListView(ListAPIView):
    queryset = Doctor.objects.filter(is_active=True).select_related("user", "clinic").prefetch_related("specializations")
    serializer_class = DoctorListSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = super().get_queryset()
        params = self.request.query_params

        clinic_id = params.get("clinic_id")
        gender = params.get("gender")
        search = params.get("search")
        min_rating = params.get("min_rating")
        is_24_7 = params.get("is_24_7")
        specialization = params.get("specialization")
        patient_type = params.get("patient_type")
        lat = params.get("lat")
        lng = params.get("lng")

        if clinic_id:
            qs = qs.filter(clinic_id=clinic_id)

        if search:
            qs = qs.filter(
                Q(user__first_name__icontains=search) |
                Q(user__last_name__icontains=search) |
                Q(clinic__name__icontains=search) |
                Q(specializations__name__icontains=search)
            ).distinct()

        if gender:
            qs = qs.filter(gender=gender)

        if is_24_7:
            qs = qs.filter(clinic__is_24_7=True)

        if specialization:
            qs = qs.filter(specializations__name__icontains=specialization)

        if patient_type:
            if patient_type == "children":
                qs = qs.filter(patient_type__in=["children", "both"])
            elif patient_type == "adults":
                qs = qs.filter(patient_type__in=["adults", "both"])

        if min_rating:
            qs = qs.annotate(_annotation_avg_rating=Avg("reviews__rating")).filter(_annotation_avg_rating__gte=float(min_rating))

        qs = qs.annotate(_annotation_avg_rating=Avg("reviews__rating"))

        if lat and lng:
            try:
                user_lat = float(lat)
                user_lng = float(lng)
                qs = qs.annotate(
                    distance_km=Value(0.0, output_field=FloatField())
                )
            except (ValueError, TypeError):
                pass

        return qs.order_by("-_annotation_avg_rating", "-id")


class NearbyDoctorsView(ListAPIView):
    serializer_class = DoctorListSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        lat = self.request.query_params.get("lat")
        lng = self.request.query_params.get("lng")
        gender = self.request.query_params.get("gender")
        search = self.request.query_params.get("search")
        min_rating = self.request.query_params.get("min_rating")
        is_24_7 = self.request.query_params.get("is_24_7")

        qs = Doctor.objects.filter(is_active=True).select_related("user", "clinic").prefetch_related("specializations")

        if not lat or not lng:
            return qs.annotate(_annotation_avg_rating=Avg("reviews__rating")).order_by("-_annotation_avg_rating")[:10]

        try:
            user_lat = float(lat)
            user_lng = float(lng)
        except (ValueError, TypeError):
            return qs.annotate(_annotation_avg_rating=Avg("reviews__rating")).order_by("-_annotation_avg_rating")[:10]

        doctors_with_distance = []
        for doctor in qs:
            if doctor.clinic.latitude and doctor.clinic.longitude:
                dlat = math.radians(float(doctor.clinic.latitude) - user_lat)
                dlng = math.radians(float(doctor.clinic.longitude) - user_lng)
                a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(user_lat)) * math.cos(math.radians(float(doctor.clinic.latitude))) * math.sin(dlng / 2) ** 2
                c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
                doctor.distance_km = round(6371 * c, 2)
            else:
                doctor.distance_km = None
            doctors_with_distance.append(doctor)

        if gender:
            doctors_with_distance = [d for d in doctors_with_distance if d.gender == gender]

        if search:
            search_lower = search.lower()
            doctors_with_distance = [
                d for d in doctors_with_distance
                if search_lower in (d.user.first_name or "").lower()
                or search_lower in (d.user.last_name or "").lower()
                or search_lower in (d.clinic.name or "").lower()
            ]

        if is_24_7:
            doctors_with_distance = [d for d in doctors_with_distance if d.clinic.is_24_7]

        doctors_with_distance.sort(key=lambda d: d.distance_km if d.distance_km is not None else float("inf"))
        return doctors_with_distance[:10]


class DoctorDetailView(RetrieveAPIView):
    queryset = Doctor.objects.filter(is_active=True).select_related("user", "clinic").prefetch_related(
        "specializations", "services", "schedules", "blocked_slots"
    )
    serializer_class = DoctorDetailSerializer
    permission_classes = [AllowAny]


class DoctorProfileView(RetrieveAPIView):
    serializer_class = DoctorDetailSerializer
    permission_classes = [IsAuthenticated, IsDoctor]

    def get_object(self):
        return Doctor.objects.select_related("user", "clinic").prefetch_related(
            "specializations", "services", "schedules", "blocked_slots"
        ).get(user=self.request.user)


class DoctorProfileUpdateView(UpdateAPIView):
    serializer_class = DoctorProfileUpdateSerializer
    permission_classes = [IsAuthenticated, IsDoctor]
    parser_classes = [MultiPartParser, FormParser]

    def get_object(self):
        return Doctor.objects.get(user=self.request.user)


class DoctorAppointmentsView(ListAPIView):
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated, IsDoctor]

    def get_queryset(self):
        doctor = Doctor.objects.get(user=self.request.user)
        return Appointment.objects.filter(doctor=doctor).select_related("patient")


class DoctorServicesView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def get(self, request):
        doctor = Doctor.objects.get(user=request.user)
        services = Service.objects.filter(doctor=doctor)
        return Response(ServiceSerializer(services, many=True).data)

    def post(self, request):
        doctor = Doctor.objects.get(user=request.user)
        serializer = ServiceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(doctor=doctor)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class DoctorServiceDetailView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def get_object(self, pk):
        doctor = Doctor.objects.get(user=self.request.user)
        return Service.objects.get(pk=pk, doctor=doctor)

    def patch(self, request, pk):
        service = self.get_object(pk)
        serializer = ServiceSerializer(service, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    def delete(self, request, pk):
        service = self.get_object(pk)
        service.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class DoctorScheduleView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def get(self, request):
        doctor = Doctor.objects.get(user=request.user)
        schedules = DoctorSchedule.objects.filter(doctor=doctor)
        return Response(DoctorScheduleSerializer(schedules, many=True).data)

    def post(self, request):
        doctor = Doctor.objects.get(user=request.user)
        serializer = DoctorScheduleSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(doctor=doctor)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class DoctorScheduleDetailView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def get_object(self, pk):
        doctor = Doctor.objects.get(user=self.request.user)
        return DoctorSchedule.objects.get(pk=pk, doctor=doctor)

    def patch(self, request, pk):
        schedule = self.get_object(pk)
        serializer = DoctorScheduleSerializer(schedule, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    def delete(self, request, pk):
        schedule = self.get_object(pk)
        schedule.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class DoctorBlockedSlotsView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def get(self, request):
        doctor = Doctor.objects.get(user=request.user)
        slots = BlockedSlot.objects.filter(doctor=doctor)
        return Response(BlockedSlotSerializer(slots, many=True).data)

    def post(self, request):
        doctor = Doctor.objects.get(user=request.user)
        serializer = BlockedSlotSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(doctor=doctor)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class DoctorBlockedSlotDetailView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def get_object(self, pk):
        doctor = Doctor.objects.get(user=self.request.user)
        return BlockedSlot.objects.get(pk=pk, doctor=doctor)

    def delete(self, request, pk):
        slot = self.get_object(pk)
        slot.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class DoctorSlotsView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def get(self, request):
        doctor = Doctor.objects.get(user=request.user)
        date_str = request.query_params.get("date")
        if date_str:
            try:
                date = datetime.date.fromisoformat(date_str)
            except ValueError:
                return Response({"error": "Invalid date"}, status=status.HTTP_400_BAD_REQUEST)
        else:
            date = datetime.date.today()

        TimeSlot.objects.generate_for_date(doctor, date)
        slots = TimeSlot.objects.filter(doctor=doctor, date=date)
        return Response({"slots": TimeSlotSerializer(slots, many=True).data})


class DoctorUploadClinicImageView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        try:
            doctor = Doctor.objects.get(user=request.user)
        except Doctor.DoesNotExist:
            return Response({"error": "Shifokor profili topilmadi"}, status=status.HTTP_404_NOT_FOUND)
        clinic = doctor.clinic
        if not clinic:
            return Response({"error": "Sizga klinika biriktirilmagan"}, status=status.HTTP_400_BAD_REQUEST)
        image = request.FILES.get("image")
        if not image:
            return Response({"error": "Rasm talab qilinadi"}, status=status.HTTP_400_BAD_REQUEST)
        gallery_image = ClinicImage.objects.create(
            clinic=clinic, image=image, uploaded_by=request.user
        )
        serializer = ClinicImageSerializer(gallery_image)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class DoctorDashboardView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def get(self, request):
        doctor = Doctor.objects.get(user=request.user)
        today = datetime.date.today()
        tomorrow = today + datetime.timedelta(days=1)

        total_appointments = Appointment.objects.filter(doctor=doctor).count()
        pending = Appointment.objects.filter(doctor=doctor, status="pending").count()
        confirmed = Appointment.objects.filter(doctor=doctor, status="confirmed").count()
        completed = Appointment.objects.filter(doctor=doctor, status="completed").count()
        cancelled = Appointment.objects.filter(doctor=doctor, status="cancelled").count()

        today_appointments = Appointment.objects.filter(doctor=doctor, appointment_date=today)
        today_count = today_appointments.count()
        tomorrow_count = Appointment.objects.filter(doctor=doctor, appointment_date=tomorrow).count()

        TimeSlot.objects.generate_for_date(doctor, today)
        today_slots = TimeSlot.objects.filter(doctor=doctor, date=today)
        total_slots_today = today_slots.count()
        booked_slots_today = today_slots.filter(status="booked").count()
        blocked_slots_today = today_slots.filter(status="blocked").count()
        available_slots_today = today_slots.filter(status="available").count()

        avg_rating = doctor.avg_rating
        review_count = doctor.review_count
        service_count = Service.objects.filter(doctor=doctor).count()

        return Response({
            "total_appointments": total_appointments,
            "pending": pending,
            "confirmed": confirmed,
            "completed": completed,
            "cancelled": cancelled,
            "today_appointments": today_count,
            "tomorrow_appointments": tomorrow_count,
            "total_slots_today": total_slots_today,
            "booked_slots_today": booked_slots_today,
            "blocked_slots_today": blocked_slots_today,
            "available_slots_today": available_slots_today,
            "avg_rating": avg_rating,
            "review_count": review_count,
            "service_count": service_count,
        })
