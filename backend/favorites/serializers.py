from rest_framework import serializers
from .models import Favorite
from backend.doctors.serializers import DoctorListSerializer


class FavoriteSerializer(serializers.ModelSerializer):
    doctor_detail = DoctorListSerializer(source="doctor", read_only=True)

    class Meta:
        model = Favorite
        fields = ("id", "user", "doctor", "doctor_detail", "created_at")
        read_only_fields = ("id", "user", "created_at")
