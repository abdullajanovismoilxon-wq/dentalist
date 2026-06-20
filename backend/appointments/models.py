from django.db import models
from django.conf import settings
from backend.doctors.models import Doctor


class Appointment(models.Model):

    STATUS_CHOICES = (
        ("pending", "Pending"),
        ("confirmed", "Confirmed"),
        ("completed", "Completed"),
        ("cancelled", "Cancelled"),
    )

    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="appointments")
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name="appointments")
    service = models.ForeignKey("services.Service", on_delete=models.SET_NULL, null=True, blank=True, related_name="appointments")
    appointment_date = models.DateField()
    appointment_time = models.TimeField()
    note = models.TextField(blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="pending")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-appointment_date", "-appointment_time"]

    def __str__(self):
        return f"{self.patient} -> {self.doctor} @ {self.appointment_date} {self.appointment_time}"
