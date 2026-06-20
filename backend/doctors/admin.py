from django.contrib import admin
from .models import Doctor, Specialization


@admin.register(Specialization)
class SpecializationAdmin(admin.ModelAdmin):
    list_display = ("name",)
    search_fields = ("name",)


@admin.register(Doctor)
class DoctorAdmin(admin.ModelAdmin):
    list_display = ("user", "clinic", "gender", "experience_years", "is_active")
    list_filter = ("is_active", "gender", "specializations")
    search_fields = ("user__first_name", "user__last_name", "clinic__name")
    filter_horizontal = ("specializations",)
    readonly_fields = ("certificate_images",)
