from django.contrib import admin
from .models import DoctorSchedule, TimeSlot, BlockedSlot


@admin.register(DoctorSchedule)
class DoctorScheduleAdmin(admin.ModelAdmin):
    list_display = ("doctor", "weekday", "start_time", "end_time", "is_24_7", "is_active")
    list_filter = ("weekday", "is_active", "is_24_7")
    search_fields = ("doctor__user__first_name",)


@admin.register(TimeSlot)
class TimeSlotAdmin(admin.ModelAdmin):
    list_display = ("doctor", "date", "start_time", "status")
    list_filter = ("status", "date")
    search_fields = ("doctor__user__first_name",)


@admin.register(BlockedSlot)
class BlockedSlotAdmin(admin.ModelAdmin):
    list_display = ("doctor", "date", "start_time", "end_time", "reason")
    list_filter = ("date",)
    search_fields = ("doctor__user__first_name", "reason")
