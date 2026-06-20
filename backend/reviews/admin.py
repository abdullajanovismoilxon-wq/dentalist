from django.contrib import admin
from .models import Review


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ("user", "doctor", "rating", "created_at")
    list_filter = ("rating",)
    search_fields = ("user__first_name", "doctor__user__first_name", "comment")
