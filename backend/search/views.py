from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q, Avg

from backend.doctors.models import Doctor, Specialization
from backend.clinics.models import Clinic
from backend.doctors.serializers import DoctorListSerializer


class GlobalSearchView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        q = request.query_params.get("q", "").strip()
        if not q or len(q) < 2:
            return Response({
                "doctors": [],
                "clinics": [],
                "specializations": [],
            })

        doctors = Doctor.objects.filter(is_active=True).select_related("user", "clinic").prefetch_related("specializations").filter(
            Q(user__first_name__icontains=q) |
            Q(user__last_name__icontains=q) |
            Q(clinic__name__icontains=q) |
            Q(specializations__name__icontains=q)
        ).distinct().annotate(_annotation_avg_rating=Avg("reviews__rating"))[:10]

        clinics = Clinic.objects.filter(
            Q(name__icontains=q) | Q(address__icontains=q) | Q(city__icontains=q)
        )[:10]

        specializations = Specialization.objects.filter(name__icontains=q)[:10]

        return Response({
            "doctors": DoctorListSerializer(doctors, many=True, context={"request": request}).data,
            "clinics": [
                {"id": c.id, "name": c.name, "address": c.address, "city": c.city}
                for c in clinics
            ],
            "specializations": [
                {"id": s.id, "name": s.name} for s in specializations
            ],
        })
