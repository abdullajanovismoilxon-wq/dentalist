from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import ChatRoom, Message
from .serializers import ChatRoomSerializer, MessageSerializer
from backend.doctors.models import Doctor


class MyChatRoomsView(ListAPIView):
    serializer_class = ChatRoomSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == "doctor":
            doctor = Doctor.objects.get(user=user)
            return ChatRoom.objects.filter(doctor=doctor).select_related("patient", "doctor__user").prefetch_related("messages")
        return ChatRoom.objects.filter(patient=user).select_related("patient", "doctor__user").prefetch_related("messages")


class ChatRoomMessagesView(ListAPIView):
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        room_id = self.kwargs["room_id"]
        user = self.request.user
        try:
            room = ChatRoom.objects.get(pk=room_id)
            if room.patient != user and room.doctor.user != user:
                return Message.objects.none()
        except ChatRoom.DoesNotExist:
            return Message.objects.none()
        return Message.objects.filter(room_id=room_id).select_related("sender")


class SendMessageView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, room_id):
        try:
            room = ChatRoom.objects.get(pk=room_id)
            if room.patient != request.user and room.doctor.user != request.user:
                return Response({"error": "Access denied"}, status=status.HTTP_403_FORBIDDEN)
        except ChatRoom.DoesNotExist:
            return Response({"error": "Room not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = MessageSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(room=room, sender=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class GetOrCreateChatRoomView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        doctor_id = request.data.get("doctor")
        if not doctor_id:
            return Response({"error": "Doctor ID required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            doctor = Doctor.objects.get(pk=doctor_id)
        except Doctor.DoesNotExist:
            return Response({"error": "Doctor not found"}, status=status.HTTP_404_NOT_FOUND)

        room, created = ChatRoom.objects.get_or_create(
            doctor=doctor,
            patient=request.user,
        )

        serializer = ChatRoomSerializer(room, context={"request": request})
        return Response(serializer.data, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)
