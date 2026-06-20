from rest_framework import serializers
from .models import Service


class ServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Service
        fields = (
            "id", "doctor", "title", "price", "duration_minutes",
            "description", "is_active", "created_at",
        )
        read_only_fields = ("id", "doctor", "created_at")
