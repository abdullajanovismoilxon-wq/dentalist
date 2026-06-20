from rest_framework import serializers
from .models import Appointment
from backend.doctors.serializers import DoctorListSerializer
from backend.users.serializers import UserSerializer
from backend.schedule.models import TimeSlot


class AppointmentSerializer(serializers.ModelSerializer):
    doctor_detail = DoctorListSerializer(source="doctor", read_only=True)
    patient_detail = UserSerializer(source="patient", read_only=True)

    class Meta:
        model = Appointment
        fields = (
            "id", "patient", "patient_detail", "doctor", "doctor_detail",
            "service", "appointment_date", "appointment_time",
            "note", "status", "created_at",
        )
        read_only_fields = ("id", "patient", "status", "created_at")


class AppointmentCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Appointment
        fields = ("doctor", "service", "appointment_date", "appointment_time", "note")

    def validate(self, attrs):
        from datetime import date as date_today
        doctor = attrs["doctor"]
        date = attrs["appointment_date"]
        time = attrs["appointment_time"]

        if date < date_today.today():
            raise serializers.ValidationError("Cannot book appointment in the past")

        if date == date_today.today():
            from datetime import datetime as dt
            now = dt.now()
            slot_dt = dt.combine(date, time)
            if slot_dt <= now:
                raise serializers.ValidationError("Cannot book a past time slot")

        slot = TimeSlot.objects.filter(
            doctor=doctor, date=date, start_time=time,
        ).first()

        if not slot:
            raise serializers.ValidationError("This time slot does not exist")

        if slot.status == "blocked":
            raise serializers.ValidationError("This time slot is blocked by the doctor")

        if slot.status == "booked":
            raise serializers.ValidationError("This time slot is already booked")

        return attrs
