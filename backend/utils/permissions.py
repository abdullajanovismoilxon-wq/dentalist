from rest_framework.permissions import BasePermission


class IsPatient(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "patient"


class IsDoctor(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "doctor"


class IsAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "admin"


class IsDoctorOrAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ("doctor", "admin")


class IsOwnerOrAdmin(BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.user.role == "admin":
            return True
        if hasattr(obj, "user"):
            return obj.user == request.user
        if hasattr(obj, "patient"):
            return obj.patient == request.user
        if hasattr(obj, "doctor"):
            return obj.doctor.user == request.user
        return obj == request.user
