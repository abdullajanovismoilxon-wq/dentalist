import datetime
from django.db import models
from backend.doctors.models import Doctor


WEEKDAY_CHOICES = (
    (0, "Monday"),
    (1, "Tuesday"),
    (2, "Wednesday"),
    (3, "Thursday"),
    (4, "Friday"),
    (5, "Saturday"),
    (6, "Sunday"),
)

GENERATION_DAYS = 90


class DoctorSchedule(models.Model):

    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name="schedules")
    weekday = models.IntegerField(choices=WEEKDAY_CHOICES)
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_24_7 = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    class Meta:
        unique_together = ("doctor", "weekday", "start_time", "end_time")
        ordering = ["weekday", "start_time"]

    def save(self, *args, **kwargs):
        if self.is_24_7:
            self.start_time = datetime.time(0, 0)
            self.end_time = datetime.time(23, 59)
        super().save(*args, **kwargs)
        TimeSlot.objects.generate_for_doctor(self.doctor)

    def delete(self, *args, **kwargs):
        doctor = self.doctor
        super().delete(*args, **kwargs)
        TimeSlot.objects.generate_for_doctor(doctor)

    def __str__(self):
        if self.is_24_7:
            return f"{self.doctor} - {self.get_weekday_display()} 24/7"
        return f"{self.doctor} - {self.get_weekday_display()} {self.start_time}-{self.end_time}"


class TimeSlotManager(models.Manager):
    use_in_migrations = True

    def generate_for_date(self, doctor, date):
        weekday = date.weekday()
        schedules = DoctorSchedule.objects.filter(doctor=doctor, weekday=weekday, is_active=True)
        if not schedules.exists():
            return

        from_date = date
        existing = set(
            self.filter(doctor=doctor, date=date).values_list("start_time", flat=True)
        )

        slots_to_create = []
        for schedule in schedules:
            if schedule.is_24_7:
                hours = list(range(24))
            else:
                start_hour = schedule.start_time.hour
                end_hour = schedule.end_time.hour
                if schedule.end_time.minute > 0 or schedule.end_time.second > 0:
                    end_hour += 1
                hours = list(range(start_hour, end_hour + 1))

            for hour in hours:
                slot_time = datetime.time(hour, 0)
                if slot_time not in existing:
                    is_blocked = BlockedSlot.objects.filter(
                        doctor=doctor, date=date,
                        start_time__lte=slot_time, end_time__gt=slot_time,
                    ).exists()
                    is_booked = doctor.appointments.filter(
                        appointment_date=date, appointment_time=slot_time,
                        status__in=("pending", "confirmed"),
                    ).exists()
                    status = "booked" if is_booked else ("blocked" if is_blocked else "available")
                    slots_to_create.append(TimeSlot(
                        doctor=doctor, date=date,
                        start_time=slot_time, status=status,
                    ))

        if slots_to_create:
            self.bulk_create(slots_to_create, ignore_conflicts=True)

    def generate_for_doctor(self, doctor):
        today = datetime.date.today()
        for i in range(GENERATION_DAYS):
            date = today + datetime.timedelta(days=i)
            self.generate_for_date(doctor, date)


class TimeSlot(models.Model):

    STATUS_CHOICES = (
        ("available", "Available"),
        ("blocked", "Blocked"),
        ("booked", "Booked"),
    )

    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name="time_slots")
    date = models.DateField()
    start_time = models.TimeField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="available")

    objects = TimeSlotManager()

    class Meta:
        unique_together = ("doctor", "date", "start_time")
        ordering = ["date", "start_time"]
        indexes = [
            models.Index(fields=["doctor", "date", "status"]),
            models.Index(fields=["doctor", "date", "start_time"]),
        ]

    def __str__(self):
        return f"{self.doctor} - {self.date} {self.start_time} ({self.status})"


class BlockedSlot(models.Model):

    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name="blocked_slots")
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    reason = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["date", "start_time"]

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        TimeSlot.objects.filter(
            doctor=self.doctor, date=self.date,
            start_time__gte=self.start_time, start_time__lt=self.end_time,
        ).exclude(status="booked").update(status="blocked")

    def delete(self, *args, **kwargs):
        super().delete(*args, **kwargs)
        TimeSlot.objects.generate_for_date(self.doctor, self.date)

    def __str__(self):
        return f"{self.doctor} - {self.date} {self.start_time}-{self.end_time}"
