from django.contrib import admin
from .models import Favorite


@admin.register(Favorite)
class FavoriteAdmin(admin.ModelAdmin):
    list_display = ("user", "doctor", "created_at")
    search_fields = ("user__first_name", "doctor__user__first_name")
