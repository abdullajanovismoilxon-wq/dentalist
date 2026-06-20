from django.db import models
from django.conf import settings
from django.db.models import Avg, Count

from backend.clinics.models import Clinic


class Specialization(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name


class Doctor(models.Model):

    GENDER_CHOICES = (
        ("male", "Male"),
        ("female", "Female"),
    )

    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    clinic = models.ForeignKey(Clinic, on_delete=models.CASCADE, related_name="doctors")
    specializations = models.ManyToManyField(Specialization)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    experience_years = models.PositiveIntegerField()
    bio = models.TextField(blank=True)
    consultation_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    image = models.ImageField(upload_to="doctors/", blank=True, null=True)
    certificate_images = models.JSONField(default=list, blank=True)
    patient_type = models.CharField(
        max_length=10,
        choices=[("adults", "Kattalar"), ("children", "Bolalar"), ("both", "Ikkalasi")],
        default="both",
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    @property
    def avg_rating(self):
        if hasattr(self, "_annotation_avg_rating") and self._annotation_avg_rating is not None:
            return round(self._annotation_avg_rating, 1)
        result = self.reviews.aggregate(avg=Avg("rating"))
        return round(result["avg"], 1) if result["avg"] else 0.0

    @property
    def review_count(self):
        return self.reviews.count()

    @property
    def rating_breakdown(self):
        counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
        qs = self.reviews.values("rating").annotate(count=Count("id"))
        for entry in qs:
            counts[entry["rating"]] = entry["count"]
        total = sum(counts.values())
        breakdown = {}
        for star, cnt in counts.items():
            breakdown[str(star)] = {
                "count": cnt,
                "percentage": round(cnt / total * 100, 1) if total > 0 else 0.0,
            }
        return breakdown

    def __str__(self):
        return self.user.get_full_name() or self.user.username
