from django.contrib import admin
from .models import ChatRoom, Message


class MessageInline(admin.TabularInline):
    model = Message
    extra = 0
    readonly_fields = ("sender", "text", "image", "is_read", "created_at")


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = ("doctor", "patient", "created_at")
    search_fields = ("doctor__user__first_name", "patient__first_name")
    inlines = [MessageInline]


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ("room", "sender", "text", "is_read", "created_at")
    list_filter = ("is_read",)
    search_fields = ("text",)
