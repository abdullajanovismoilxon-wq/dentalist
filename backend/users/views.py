from django.db import transaction

from rest_framework import status
from rest_framework.generics import CreateAPIView, RetrieveUpdateAPIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User
from .serializers import RegisterSerializer, DoctorRegisterSerializer, UserSerializer, UserUpdateSerializer, LoginSerializer
from backend.clinics.models import Clinic
from backend.doctors.models import Doctor, Specialization
from backend.schedule.models import DoctorSchedule


class RegisterView(CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            "user": UserSerializer(user).data,
            "refresh": str(refresh),
            "access": str(refresh.access_token),
        }, status=status.HTTP_201_CREATED)


class DoctorRegisterView(CreateAPIView):
    permission_classes = [AllowAny]
    serializer_class = DoctorRegisterSerializer

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        password = data.pop("password")
        data.pop("password2")

        user = User(
            username=data["phone"],
            first_name=data["first_name"],
            last_name=data["last_name"],
            phone=data["phone"],
            gender=data.get("gender", ""),
            role="doctor",
        )
        user.set_password(password)
        user.save()

        clinic, _ = Clinic.objects.get_or_create(
            name=data["clinic_name"],
            defaults={
                "address": data.get("clinic_address", ""),
                "latitude": data.get("latitude"),
                "longitude": data.get("longitude"),
                "formatted_address": data.get("formatted_address", ""),
            },
        )

        doctor = Doctor.objects.create(
            user=user,
            clinic=clinic,
            gender=data.get("gender", "male"),
            experience_years=data.get("experience_years", 0),
            bio=data.get("bio", ""),
            image=data.get("image"),
            patient_type=data.get("patient_type", "both"),
        )

        spec_names = data.get("specializations", [])
        for name in spec_names:
            spec, _ = Specialization.objects.get_or_create(name=name.strip())
            doctor.specializations.add(spec)

        refresh = RefreshToken.for_user(user)
        return Response({
            "user": UserSerializer(user).data,
            "refresh": str(refresh),
            "access": str(refresh.access_token),
        }, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        refresh = RefreshToken.for_user(user)
        return Response({
            "user": UserSerializer(user).data,
            "refresh": str(refresh),
            "access": str(refresh.access_token),
        })


class ProfileView(RetrieveUpdateAPIView):
    serializer_class = UserUpdateSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_object(self):
        return self.request.user
