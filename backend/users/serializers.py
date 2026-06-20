from rest_framework import serializers
from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            "id", "username", "first_name", "last_name", "email",
            "phone", "avatar", "role", "blood_group", "allergies",
            "date_of_birth", "gender",
        )
        read_only_fields = ("id", "role")


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password2 = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = (
            "first_name", "last_name", "phone", "password", "password2",
            "avatar", "blood_group", "allergies", "date_of_birth", "gender",
        )

    def validate_phone(self, value):
        if User.objects.filter(phone=value).exists():
            raise serializers.ValidationError("Phone number already registered")
        return value

    def validate(self, attrs):
        if attrs["password"] != attrs["password2"]:
            raise serializers.ValidationError({"password2": "Passwords do not match"})
        return attrs

    def create(self, validated_data):
        validated_data.pop("password2")
        password = validated_data.pop("password")
        validated_data["username"] = validated_data["phone"]
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user


class DoctorRegisterSerializer(serializers.Serializer):
    first_name = serializers.CharField()
    last_name = serializers.CharField()
    phone = serializers.CharField()
    password = serializers.CharField(write_only=True, min_length=8)
    password2 = serializers.CharField(write_only=True, min_length=8)
    gender = serializers.ChoiceField(choices=User.GENDER_CHOICES)
    experience_years = serializers.IntegerField(min_value=0)
    bio = serializers.CharField(required=False, allow_blank=True)
    image = serializers.ImageField(required=False)

    clinic_name = serializers.CharField()
    clinic_address = serializers.CharField(required=False, allow_blank=True)
    latitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False, allow_null=True)
    longitude = serializers.DecimalField(max_digits=9, decimal_places=6, required=False, allow_null=True)
    formatted_address = serializers.CharField(required=False, allow_blank=True)
    specializations = serializers.ListField(child=serializers.CharField(), required=False)
    patient_type = serializers.ChoiceField(choices=["adults", "children", "both"], default="both")
    working_hours = serializers.JSONField(required=False)

    def validate_phone(self, value):
        if User.objects.filter(phone=value).exists():
            raise serializers.ValidationError("Phone number already registered")
        return value

    def validate(self, attrs):
        if attrs["password"] != attrs["password2"]:
            raise serializers.ValidationError({"password2": "Passwords do not match"})
        return attrs


class LoginSerializer(serializers.Serializer):
    phone = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        from django.contrib.auth import authenticate
        from backend.doctors.models import Doctor
        user = authenticate(request=self.context.get("request"), phone=attrs["phone"], password=attrs["password"])
        if not user:
            raise serializers.ValidationError("Telefon raqam yoki parol noto'g'ri")
        if not user.is_active:
            raise serializers.ValidationError("Hisob faol emas")
        if user.role == "doctor" and not Doctor.objects.filter(user=user).exists():
            raise serializers.ValidationError("Shifokor profili to'liq yaratilmagan. Iltimos, qayta ro'yxatdan o'ting.")
        attrs["user"] = user
        return attrs


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            "first_name", "last_name", "email", "phone",
            "avatar", "blood_group", "allergies", "date_of_birth", "gender",
        )
