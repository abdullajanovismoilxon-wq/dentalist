from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import RegisterView, DoctorRegisterView, LoginView, ProfileView

urlpatterns = [
    path("register/", RegisterView.as_view(), name="user-register"),
    path("register/doctor/", DoctorRegisterView.as_view(), name="doctor-register"),
    path("login/", LoginView.as_view(), name="user-login"),
    path("refresh/", TokenRefreshView.as_view(), name="token-refresh"),
    path("profile/", ProfileView.as_view(), name="user-profile"),
]
