from django.contrib import admin
from .models import Clinic, ClinicImage, ClinicReview


class ClinicImageInline(admin.TabularInline):
    model = ClinicImage
    extra = 1


@admin.register(Clinic)
class ClinicAdmin(admin.ModelAdmin):
    list_display = ("name", "address", "city", "phone", "is_24_7")
    list_filter = ("is_24_7", "city")
    search_fields = ("name", "address", "city")
    inlines = [ClinicImageInline]


@admin.register(ClinicImage)
class ClinicImageAdmin(admin.ModelAdmin):
    list_display = ("id", "clinic", "uploaded_by", "created_at")
    list_filter = ("created_at",)


@admin.register(ClinicReview)
class ClinicReviewAdmin(admin.ModelAdmin):
    list_display = ("user", "clinic", "rating", "created_at")
    list_filter = ("rating",)
    search_fields = ("user__first_name", "clinic__name", "comment")
