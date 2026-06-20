from django.urls import path
from .views import (
    MyChatRoomsView, ChatRoomMessagesView,
    SendMessageView, GetOrCreateChatRoomView,
)

urlpatterns = [
    path("rooms/", MyChatRoomsView.as_view(), name="my-chat-rooms"),
    path("rooms/get-or-create/", GetOrCreateChatRoomView.as_view(), name="get-or-create-room"),
    path("rooms/<int:room_id>/messages/", ChatRoomMessagesView.as_view(), name="room-messages"),
    path("rooms/<int:room_id>/send/", SendMessageView.as_view(), name="send-message"),
]
