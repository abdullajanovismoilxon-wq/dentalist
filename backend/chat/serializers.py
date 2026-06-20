from rest_framework import serializers
from .models import ChatRoom, Message
from backend.users.serializers import UserSerializer
from backend.doctors.serializers import DoctorListSerializer


class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source="sender.get_full_name", read_only=True)

    class Meta:
        model = Message
        fields = ("id", "room", "sender", "sender_name", "text", "image", "is_read", "created_at")
        read_only_fields = ("id", "room", "sender", "is_read", "created_at")


class ChatRoomSerializer(serializers.ModelSerializer):
    patient_detail = UserSerializer(source="patient", read_only=True)
    doctor_detail = DoctorListSerializer(source="doctor", read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = ("id", "patient", "patient_detail", "doctor", "doctor_detail", "last_message", "unread_count", "created_at", "updated_at")
        read_only_fields = ("id", "created_at", "updated_at")

    def get_last_message(self, obj):
        message = obj.messages.last()
        if message:
            return {
                "text": message.text[:100],
                "sender": message.sender_id,
                "created_at": message.created_at.isoformat(),
            }
        return None

    def get_unread_count(self, obj):
        request = self.context.get("request")
        if not request:
            return 0
        return obj.messages.exclude(sender=request.user).filter(is_read=False).count()
