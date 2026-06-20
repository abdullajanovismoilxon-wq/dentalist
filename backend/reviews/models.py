from django.db import models
from django.conf import settings

from backend.doctors.models import Doctor


class Review(models.Model):

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="reviews"
    )

    doctor = models.ForeignKey(
        Doctor,
        on_delete=models.CASCADE,
        related_name="reviews"
    )

    rating = models.PositiveSmallIntegerField(
        choices=[
            (1, "1"),
            (2, "2"),
            (3, "3"),
            (4, "4"),
            (5, "5"),
        ]
    )

    comment = models.TextField(
        blank=True
    )



    created_at = models.DateTimeField(
        auto_now_add=True
    )

    class Meta:
        unique_together = (
            "user",
            "doctor"
        )

    def __str__(self):
        return f"{self.user} -> {self.doctor} ({self.rating})"