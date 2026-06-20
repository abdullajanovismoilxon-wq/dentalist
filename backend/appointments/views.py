import datetime
from rest_framework import status
from rest_framework.generics import ListAPIView, CreateAPIView, RetrieveUpdateAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Appointment
from .serializers import AppointmentSerializer, AppointmentCreateSerializer
from backend.doctors.models import Doctor
from backend.schedule.models import TimeSlot
from backend.utils.permissions import IsPatient


class MyAppointmentsView(ListAPIView):
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == "doctor":
            doctor = Doctor.objects.get(user=user)
            return Appointment.objects.filter(doctor=doctor)
        return Appointment.objects.filter(patient=user)


class CreateAppointmentView(CreateAPIView):
    queryset = Appointment.objects.all()
    serializer_class = AppointmentCreateSerializer
    permission_classes = [IsAuthenticated, IsPatient]

    def perform_create(self, serializer):
        appointment = serializer.save(patient=self.request.user)
        TimeSlot.objects.filter(
            doctor=appointment.doctor,
            date=appointment.appointment_date,
            start_time=appointment.appointment_time,
        ).update(status="booked")


class AppointmentDetailView(RetrieveUpdateAPIView):
    queryset = Appointment.objects.all()
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == "doctor":
            doctor = Doctor.objects.get(user=user)
            return Appointment.objects.filter(doctor=doctor)
        return Appointment.objects.filter(patient=user)


class CancelAppointmentView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        user = request.user
        try:
            if user.role == "doctor":
                doctor = Doctor.objects.get(user=user)
                appointment = Appointment.objects.get(pk=pk, doctor=doctor)
            else:
                appointment = Appointment.objects.get(pk=pk, patient=user)
        except Appointment.DoesNotExist:
            return Response({"error": "Appointment not found"}, status=status.HTTP_404_NOT_FOUND)

        if appointment.status in ("completed", "cancelled"):
            return Response({"error": "Cannot cancel this appointment"}, status=status.HTTP_400_BAD_REQUEST)

        appointment.status = "cancelled"
        appointment.save()

        TimeSlot.objects.filter(
            doctor=appointment.doctor,
            date=appointment.appointment_date,
            start_time=appointment.appointment_time,
        ).update(status="available")

        return Response(AppointmentSerializer(appointment).data)


class ConfirmAppointmentView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        try:
            doctor = Doctor.objects.get(user=request.user)
            appointment = Appointment.objects.get(pk=pk, doctor=doctor)
        except (Doctor.DoesNotExist, Appointment.DoesNotExist):
            return Response({"error": "Not found"}, status=status.HTTP_404_NOT_FOUND)

        if appointment.status != "pending":
            return Response({"error": "Appointment is not pending"}, status=status.HTTP_400_BAD_REQUEST)

        appointment.status = "confirmed"
        appointment.save()
        return Response(AppointmentSerializer(appointment).data)


class AvailableTimesView(APIView):
    permission_classes = []

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

        from backend.schedule.serializers import TimeSlotSerializer

        TimeSlot.objects.generate_for_date(doctor, date)

        slots = TimeSlot.objects.filter(doctor=doctor, date=date)
        return Response({"slots": TimeSlotSerializer(slots, many=True).data})
