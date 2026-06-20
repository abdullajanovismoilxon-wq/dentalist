from django.urls import path
from .views import DoctorReviewsView, CreateReviewView, CheckReviewView

urlpatterns = [
    path("doctor/<int:doctor_id>/", DoctorReviewsView.as_view(), name="doctor-reviews"),
    path("create/", CreateReviewView.as_view(), name="create-review"),
    path("check/<int:doctor_id>/", CheckReviewView.as_view(), name="check-review"),
]
