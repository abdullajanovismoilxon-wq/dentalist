from django.urls import path
from .views import AvailableTimesView

urlpatterns = [
    path("available-times/<int:doctor_id>/", AvailableTimesView.as_view(), name="available-times"),
]
