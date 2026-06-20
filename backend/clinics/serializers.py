from rest_framework import serializers
from .models import Clinic, ClinicImage, ClinicReview
from backend.users.serializers import UserSerializer


class ClinicImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClinicImage
        fields = ("id", "clinic", "image", "uploaded_by", "created_at")
        read_only_fields = ("id", "clinic", "uploaded_by", "created_at")


class ClinicReviewSerializer(serializers.ModelSerializer):
    user_detail = UserSerializer(source="user", read_only=True)

    class Meta:
        model = ClinicReview
        fields = ("id", "user", "user_detail", "clinic", "rating", "comment", "created_at")
        read_only_fields = ("id", "user", "created_at")


class ClinicSerializer(serializers.ModelSerializer):
    avg_rating = serializers.FloatField(read_only=True)
    review_count = serializers.IntegerField(read_only=True)
    doctors_count = serializers.IntegerField(read_only=True)
    rating_breakdown = serializers.DictField(read_only=True)
    gallery = ClinicImageSerializer(many=True, read_only=True)
    distance_km = serializers.SerializerMethodField()

    class Meta:
        model = Clinic
        fields = (
            "id", "name", "description", "address", "city", "phone",
            "is_24_7", "image", "latitude", "longitude",
            "formatted_address", "avg_rating", "review_count",
            "doctors_count", "rating_breakdown", "gallery",
            "created_at", "distance_km",
        )

    def get_distance_km(self, obj):
        return getattr(obj, "distance_km", None)
