from django.db import models
from backend.doctors.models import Doctor


class Service(models.Model):

    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name="services")
    title = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    duration_minutes = models.PositiveIntegerField(default=60)
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["title"]

    def __str__(self):
        return f"{self.title} - ${self.price}"
