from django.urls import path
from .views import (
    MyAppointmentsView, CreateAppointmentView,
    AppointmentDetailView, CancelAppointmentView,
    ConfirmAppointmentView, AvailableTimesView,
)

urlpatterns = [
    path("", MyAppointmentsView.as_view(), name="my-appointments"),
    path("create/", CreateAppointmentView.as_view(), name="create-appointment"),
    path("<int:pk>/", AppointmentDetailView.as_view(), name="appointment-detail"),
    path("<int:pk>/cancel/", CancelAppointmentView.as_view(), name="cancel-appointment"),
    path("<int:pk>/confirm/", ConfirmAppointmentView.as_view(), name="confirm-appointment"),
]
