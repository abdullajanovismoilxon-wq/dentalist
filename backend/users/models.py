from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):

    ROLE_CHOICES = (
        ("patient", "Patient"),
        ("doctor", "Doctor"),
        ("admin", "Admin"),
    )

    GENDER_CHOICES = (
        ("male", "Male"),
        ("female", "Female"),
    )

    BLOOD_GROUP_CHOICES = (
        ("I+", "I+"),
        ("I-", "I-"),
        ("II+", "II+"),
        ("II-", "II-"),
        ("III+", "III+"),
        ("III-", "III-"),
        ("IV+", "IV+"),
        ("IV-", "IV-"),
    )

    phone = models.CharField(max_length=20, unique=True)
    avatar = models.ImageField(upload_to="avatars/", blank=True, null=True, default=None)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default="patient")

    USERNAME_FIELD = "phone"
    REQUIRED_FIELDS = []

    blood_group = models.CharField(max_length=5, choices=BLOOD_GROUP_CHOICES, blank=True)
    allergies = models.TextField(blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, blank=True)

    def __str__(self):
        return self.get_full_name() or self.username
