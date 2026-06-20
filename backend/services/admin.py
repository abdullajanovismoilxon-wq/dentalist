from django.contrib import admin
from .models import Service


@admin.register(Service)
class ServiceAdmin(admin.ModelAdmin):
    list_display = ("title", "doctor", "price", "duration_minutes", "is_active")
    list_filter = ("is_active",)
    search_fields = ("title", "doctor__user__first_name")
