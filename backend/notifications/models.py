from django.db import models
from django.conf import settings


class Notification(models.Model):

    TYPE_CHOICES = (
        ("new_message", "New Message"),
        ("appointment_booked", "Appointment Booked"),
        ("appointment_confirmed", "Appointment Confirmed"),
        ("appointment_cancelled", "Appointment Cancelled"),
    )

    recipient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="notifications")
    type = models.CharField(max_length=30, choices=TYPE_CHOICES)
    title = models.CharField(max_length=200)
    message = models.TextField()
    data = models.JSONField(default=dict, blank=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.recipient} - {self.title}"
