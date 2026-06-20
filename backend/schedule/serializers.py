from rest_framework import serializers
from .models import DoctorSchedule, TimeSlot, BlockedSlot


class DoctorScheduleSerializer(serializers.ModelSerializer):
    weekday_display = serializers.CharField(source="get_weekday_display", read_only=True)

    class Meta:
        model = DoctorSchedule
        fields = (
            "id", "doctor", "weekday", "weekday_display",
            "start_time", "end_time", "is_24_7", "is_active",
        )
        read_only_fields = ("id", "doctor")


class TimeSlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = TimeSlot
        fields = ("id", "doctor", "date", "start_time", "status")


class TimeSlotToggleSerializer(serializers.Serializer):
    reason = serializers.CharField(required=False, allow_blank=True, max_length=200)


class BlockedSlotSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlockedSlot
        fields = (
            "id", "doctor", "date", "start_time", "end_time", "reason",
        )
        read_only_fields = ("id", "doctor")
