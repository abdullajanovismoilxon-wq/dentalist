import datetime
from rest_framework import status
from rest_framework.generics import ListAPIView, CreateAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import DoctorSchedule, TimeSlot, BlockedSlot
from .serializers import (
    DoctorScheduleSerializer, TimeSlotSerializer,
    TimeSlotToggleSerializer, BlockedSlotSerializer,
)
from backend.doctors.models import Doctor
from backend.utils.permissions import IsDoctor


class DoctorScheduleListView(ListAPIView):
    queryset = DoctorSchedule.objects.filter(is_active=True)
    serializer_class = DoctorScheduleSerializer
    permission_classes = [AllowAny]
    filterset_fields = ("doctor", "weekday")


class BlockedSlotListView(ListAPIView):
    queryset = BlockedSlot.objects.all()
    serializer_class = BlockedSlotSerializer
    permission_classes = [AllowAny]
    filterset_fields = ("doctor", "date")


class TimeSlotForDateView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, doctor_id):
        date_str = request.query_params.get("date")
        if not date_str:
            return Response({"error": "Date is required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            date = datetime.date.fromisoformat(date_str)
        except ValueError:
            return Response({"error": "Invalid date format"}, status=status.HTTP_400_BAD_REQUEST)

        if date < datetime.date.today():
            return Response({"slots": []})

        try:
            doctor = Doctor.objects.get(pk=doctor_id)
        except Doctor.DoesNotExist:
            return Response({"error": "Doctor not found"}, status=status.HTTP_404_NOT_FOUND)

        TimeSlot.objects.generate_for_date(doctor, date)

        slots = TimeSlot.objects.filter(doctor=doctor, date=date)
        return Response({
            "slots": TimeSlotSerializer(slots, many=True).data,
        })


class ToggleSlotBlockView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def patch(self, request, slot_id):
        doctor = Doctor.objects.get(user=request.user)
        try:
            slot = TimeSlot.objects.get(pk=slot_id, doctor=doctor)
        except TimeSlot.DoesNotExist:
            return Response({"error": "Slot not found"}, status=status.HTTP_404_NOT_FOUND)

        if slot.status == "booked":
            return Response({"error": "Cannot block a booked slot"}, status=status.HTTP_400_BAD_REQUEST)

        new_status = "blocked" if slot.status == "available" else "available"
        slot.status = new_status
        slot.save()

        return Response(TimeSlotSerializer(slot).data)


class BulkToggleSlotsView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def patch(self, request):
        doctor = Doctor.objects.get(user=request.user)
        slot_ids = request.data.get("slot_ids", [])
        action = request.data.get("action", "toggle")

        if not slot_ids:
            return Response({"error": "slot_ids required"}, status=status.HTTP_400_BAD_REQUEST)

        slots = TimeSlot.objects.filter(pk__in=slot_ids, doctor=doctor)
        updated = []
        for slot in slots:
            if slot.status == "booked":
                continue
            if action == "block":
                slot.status = "blocked"
            elif action == "unblock":
                if slot.status == "blocked":
                    slot.status = "available"
            elif action == "toggle":
                slot.status = "blocked" if slot.status == "available" else "available"
            slot.save()
            updated.append(slot)

        return Response(TimeSlotSerializer(updated, many=True).data)


class GenerateSlotsForDateView(APIView):
    permission_classes = [IsAuthenticated, IsDoctor]

    def post(self, request):
        doctor = Doctor.objects.get(user=request.user)
        date_str = request.data.get("date")
        if date_str:
            try:
                date = datetime.date.fromisoformat(date_str)
            except ValueError:
                return Response({"error": "Invalid date"}, status=status.HTTP_400_BAD_REQUEST)
            TimeSlot.objects.generate_for_date(doctor, date)
        else:
            TimeSlot.objects.generate_for_doctor(doctor)

        return Response({"status": "ok"})
