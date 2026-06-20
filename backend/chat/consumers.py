import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model

User = get_user_model()


class ChatConsumer(AsyncWebsocketConsumer):

    async def connect(self):
        self.room_id = self.scope["url_route"]["kwargs"]["room_id"]
        self.room_group_name = f"chat_{self.room_id}"

        user = self.scope.get("user")
        if not user or not user.is_authenticated:
            await self.close()
            return

        can_join = await self._can_access_room(user, self.room_id)
        if not can_join:
            await self.close()
            return

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        msg_type = data.get("type")

        if msg_type == "send_message":
            text = data.get("text", "").strip()
            if not text:
                return
            user = self.scope["user"]
            message = await self._save_message(self.room_id, user, text)
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    "type": "chat_message",
                    "id": message.id,
                    "sender": user.id,
                    "sender_name": user.get_full_name() or user.username,
                    "text": text,
                    "created_at": message.created_at.isoformat(),
                },
            )

        elif msg_type == "typing":
            user = self.scope["user"]
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    "type": "typing_indicator",
                    "user_id": user.id,
                    "user_name": user.get_full_name() or user.username,
                },
            )

        elif msg_type == "mark_read":
            await self._mark_read(self.room_id, self.scope["user"])

    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event))

    async def typing_indicator(self, event):
        await self.send(text_data=json.dumps(event))

    @database_sync_to_async
    def _can_access_room(self, user, room_id):
        from .models import ChatRoom
        try:
            room = ChatRoom.objects.get(pk=room_id)
            return room.patient == user or room.doctor.user == user
        except ChatRoom.DoesNotExist:
            return False

    @database_sync_to_async
    def _save_message(self, room_id, user, text):
        from .models import ChatRoom, Message
        room = ChatRoom.objects.get(pk=room_id)
        return Message.objects.create(room=room, sender=user, text=text)

    @database_sync_to_async
    def _mark_read(self, room_id, user):
        from .models import Message
        Message.objects.filter(room_id=room_id).exclude(sender=user).update(is_read=True)
