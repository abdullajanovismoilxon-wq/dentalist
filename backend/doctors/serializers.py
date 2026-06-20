from rest_framework import serializers
from .models import Doctor, Specialization
from backend.clinics.serializers import ClinicSerializer
from backend.services.serializers import ServiceSerializer
from backend.schedule.serializers import BlockedSlotSerializer, DoctorScheduleSerializer


class SpecializationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Specialization
        fields = ("id", "name")


class DoctorListSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    specializations = SpecializationSerializer(many=True)
    clinic_name = serializers.CharField(source="clinic.name", read_only=True)
    clinic_address = serializers.CharField(source="clinic.address", read_only=True)
    clinic_latitude = serializers.DecimalField(source="clinic.latitude", max_digits=9, decimal_places=6, read_only=True, allow_null=True)
    clinic_longitude = serializers.DecimalField(source="clinic.longitude", max_digits=9, decimal_places=6, read_only=True, allow_null=True)
    avg_rating = serializers.FloatField(read_only=True)
    review_count = serializers.IntegerField(read_only=True)
    distance_km = serializers.SerializerMethodField()

    class Meta:
        model = Doctor
        fields = (
            "id", "full_name", "image", "gender", "experience_years",
            "specializations", "clinic_name", "clinic_address",
            "clinic_latitude", "clinic_longitude",
            "consultation_price", "avg_rating", "review_count",
            "is_active", "distance_km", "patient_type",
        )

    def get_full_name(self, obj):
        return obj.user.get_full_name() or obj.user.username

    def get_distance_km(self, obj):
        return getattr(obj, "distance_km", None)


class DoctorDetailSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    phone = serializers.CharField(source="user.phone", read_only=True)
    specializations = SpecializationSerializer(many=True)
    clinic = ClinicSerializer(read_only=True)
    services = ServiceSerializer(many=True, read_only=True)
    schedules = DoctorScheduleSerializer(many=True, read_only=True)
    blocked_slots = BlockedSlotSerializer(many=True, read_only=True)
    avg_rating = serializers.FloatField(read_only=True)
    review_count = serializers.IntegerField(read_only=True)
    rating_breakdown = serializers.DictField(read_only=True)
    is_favorited = serializers.SerializerMethodField()

    class Meta:
        model = Doctor
        fields = (
            "id", "full_name", "image", "gender", "experience_years",
            "bio", "phone", "specializations", "clinic",
            "consultation_price", "services", "schedules", "blocked_slots",
            "avg_rating", "review_count", "rating_breakdown",
            "is_active", "is_favorited",
            "certificate_images", "patient_type", "created_at",
        )

    def get_full_name(self, obj):
        return obj.user.get_full_name() or obj.user.username

    def get_is_favorited(self, obj):
        request = self.context.get("request")
        if request and request.user.is_authenticated:
            return obj.favorited_by.filter(user=request.user).exists()
        return False


class DoctorProfileUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Doctor
        fields = (
            "image", "gender", "experience_years", "bio",
            "consultation_price", "is_active", "certificate_images",
            "patient_type",
        )
