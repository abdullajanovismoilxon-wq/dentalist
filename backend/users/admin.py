from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ("phone", "first_name", "last_name", "role", "is_active")
    list_filter = ("role", "is_active")
    search_fields = ("phone", "first_name", "last_name")
    fieldsets = BaseUserAdmin.fieldsets + (
        ("Extra Info", {"fields": ("phone", "role", "avatar", "blood_group", "allergies", "date_of_birth", "gender")}),
    )
