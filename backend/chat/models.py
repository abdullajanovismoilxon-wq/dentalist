from django.db import models
from django.conf import settings
from backend.doctors.models import Doctor


class ChatRoom(models.Model):

    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name="chat_rooms")
    patient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="chat_rooms")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("doctor", "patient")

    def __str__(self):
        return f"{self.doctor} - {self.patient}"


class Message(models.Model):

    room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name="messages")
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="sent_messages")
    text = models.TextField(blank=True)
    image = models.ImageField(upload_to="chat_images/", blank=True, null=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at"]

    def __str__(self):
        return f"{self.sender}: {self.text[:50]}"
