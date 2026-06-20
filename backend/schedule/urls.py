from django.urls import path
from .views import (
    DoctorScheduleListView, BlockedSlotListView,
    TimeSlotForDateView, ToggleSlotBlockView,
    BulkToggleSlotsView, GenerateSlotsForDateView,
)

urlpatterns = [
    path("schedules/", DoctorScheduleListView.as_view(), name="schedule-list"),
    path("blocked/", BlockedSlotListView.as_view(), name="blocked-list"),
    path("slots/<int:doctor_id>/", TimeSlotForDateView.as_view(), name="time-slots"),
    path("slots/<int:slot_id>/toggle-block/", ToggleSlotBlockView.as_view(), name="toggle-slot-block"),
    path("slots/bulk-toggle/", BulkToggleSlotsView.as_view(), name="bulk-toggle-slots"),
    path("generate/", GenerateSlotsForDateView.as_view(), name="generate-slots"),
]
