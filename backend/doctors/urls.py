from django.urls import path
from .views import (
    SpecializationListView,
    DoctorListView, NearbyDoctorsView, DoctorDetailView,
    DoctorProfileView, DoctorProfileUpdateView, DoctorAppointmentsView,
    DoctorServicesView, DoctorServiceDetailView,
    DoctorScheduleView, DoctorScheduleDetailView,
    DoctorBlockedSlotsView, DoctorBlockedSlotDetailView,
    DoctorDashboardView, DoctorUploadClinicImageView, DoctorSlotsView,
)

urlpatterns = [
    path("specializations/", SpecializationListView.as_view(), name="specialization-list"),
    path("", DoctorListView.as_view(), name="doctor-list"),
    path("nearby/", NearbyDoctorsView.as_view(), name="doctor-nearby"),
    path("profile/", DoctorProfileView.as_view(), name="doctor-profile"),
    path("profile/update/", DoctorProfileUpdateView.as_view(), name="doctor-profile-update"),
    path("appointments/", DoctorAppointmentsView.as_view(), name="doctor-appointments"),
    path("services/", DoctorServicesView.as_view(), name="doctor-services"),
    path("services/<int:pk>/", DoctorServiceDetailView.as_view(), name="doctor-service-detail"),
    path("schedule/", DoctorScheduleView.as_view(), name="doctor-schedule"),
    path("schedule/<int:pk>/", DoctorScheduleDetailView.as_view(), name="doctor-schedule-detail"),
    path("blocked-slots/", DoctorBlockedSlotsView.as_view(), name="doctor-blocked-slots"),
    path("blocked-slots/<int:pk>/", DoctorBlockedSlotDetailView.as_view(), name="doctor-blocked-slot-detail"),
    path("slots/", DoctorSlotsView.as_view(), name="doctor-slots"),
    path("dashboard/", DoctorDashboardView.as_view(), name="doctor-dashboard"),
    path("clinic/upload-image/", DoctorUploadClinicImageView.as_view(), name="doctor-upload-clinic-image"),
    path("<int:pk>/", DoctorDetailView.as_view(), name="doctor-detail"),
]
