from django.db import models
from django.conf import settings
from django.db.models import Avg, Count


class Clinic(models.Model):

    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    address = models.CharField(max_length=255, blank=True)
    city = models.CharField(max_length=100, blank=True)
    phone = models.CharField(max_length=20, blank=True)
    is_24_7 = models.BooleanField(default=False)
    image = models.ImageField(upload_to="clinics/", blank=True, null=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    formatted_address = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    @property
    def avg_rating(self):
        if hasattr(self, "_annotation_avg_rating") and self._annotation_avg_rating is not None:
            return round(self._annotation_avg_rating, 1)
        result = self.reviews.aggregate(avg=Avg("rating"))
        return round(result["avg"], 1) if result["avg"] else 0.0

    @property
    def review_count(self):
        if hasattr(self, "_annotation_review_count") and self._annotation_review_count is not None:
            return self._annotation_review_count
        return self.reviews.count()

    @property
    def doctors_count(self):
        if hasattr(self, "_annotation_doctors_count") and self._annotation_doctors_count is not None:
            return self._annotation_doctors_count
        return self.doctors.count()

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
        return self.name


class ClinicImage(models.Model):
    clinic = models.ForeignKey(Clinic, on_delete=models.CASCADE, related_name="gallery")
    image = models.ImageField(upload_to="clinics/gallery/")
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.clinic.name} - {self.id}"


class ClinicReview(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="clinic_reviews",
    )
    clinic = models.ForeignKey(
        Clinic, on_delete=models.CASCADE, related_name="reviews"
    )
    rating = models.PositiveSmallIntegerField(
        choices=[(1, "1"), (2, "2"), (3, "3"), (4, "4"), (5, "5")]
    )
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("user", "clinic")

    def __str__(self):
        return f"{self.user} -> {self.clinic} ({self.rating})"
