from django.urls import path
from .views import (
    ClinicListView, ClinicDetailView,
    ClinicGalleryUploadView, GalleryImageDeleteView,
    ClinicReviewsView, CreateClinicReviewView,
    CheckClinicReviewView, UpdateClinicReviewView,
    ClinicAvatarUploadView,
)

urlpatterns = [
    path("", ClinicListView.as_view(), name="clinic-list"),
    path("<int:pk>/", ClinicDetailView.as_view(), name="clinic-detail"),
    path("gallery/<int:pk>/delete/", GalleryImageDeleteView.as_view(), name="gallery-image-delete"),
    path("<int:clinic_id>/gallery/upload/", ClinicGalleryUploadView.as_view(), name="clinic-gallery-upload"),
    path("<int:clinic_id>/reviews/", ClinicReviewsView.as_view(), name="clinic-reviews"),
    path("<int:clinic_id>/reviews/create/", CreateClinicReviewView.as_view(), name="create-clinic-review"),
    path("<int:clinic_id>/reviews/check/", CheckClinicReviewView.as_view(), name="check-clinic-review"),
    path("<int:clinic_id>/reviews/update/", UpdateClinicReviewView.as_view(), name="update-clinic-review"),
    path("<int:pk>/avatar/", ClinicAvatarUploadView.as_view(), name="clinic-avatar"),
]
