from rest_framework import status
from rest_framework.generics import ListAPIView, CreateAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Review
from .serializers import ReviewSerializer
from backend.doctors.models import Doctor
from backend.utils.permissions import IsPatient


class DoctorReviewsView(ListAPIView):
    serializer_class = ReviewSerializer
    permission_classes = []

    def get_queryset(self):
        doctor_id = self.kwargs.get("doctor_id")
        return Review.objects.filter(doctor_id=doctor_id).select_related("user")


class CreateReviewView(CreateAPIView):
    queryset = Review.objects.all()
    serializer_class = ReviewSerializer
    permission_classes = [IsAuthenticated, IsPatient]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class CheckReviewView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, doctor_id):
        has_reviewed = Review.objects.filter(user=request.user, doctor_id=doctor_id).exists()
        return Response({"has_reviewed": has_reviewed})
