from rest_framework import serializers
from .models import Review
from backend.users.serializers import UserSerializer


class ReviewSerializer(serializers.ModelSerializer):
    user_detail = UserSerializer(source="user", read_only=True)

    class Meta:
        model = Review
        fields = ("id", "user", "user_detail", "doctor", "rating", "comment", "created_at")
        read_only_fields = ("id", "user", "created_at")
