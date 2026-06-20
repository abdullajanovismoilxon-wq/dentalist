from rest_framework import status
from rest_framework.generics import ListAPIView, CreateAPIView, DestroyAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Favorite
from .serializers import FavoriteSerializer
from backend.doctors.models import Doctor
from backend.utils.permissions import IsPatient


class MyFavoritesView(ListAPIView):
    serializer_class = FavoriteSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Favorite.objects.filter(user=self.request.user).select_related("doctor__user", "doctor__clinic")


class AddFavoriteView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        doctor_id = request.data.get("doctor")
        if not doctor_id:
            return Response({"error": "Doctor ID is required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            doctor = Doctor.objects.get(pk=doctor_id)
        except Doctor.DoesNotExist:
            return Response({"error": "Doctor not found"}, status=status.HTTP_404_NOT_FOUND)

        favorite, created = Favorite.objects.get_or_create(user=request.user, doctor=doctor)
        if not created:
            return Response({"message": "Already in favorites"}, status=status.HTTP_200_OK)

        return Response(FavoriteSerializer(favorite).data, status=status.HTTP_201_CREATED)


class RemoveFavoriteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, doctor_id):
        deleted, _ = Favorite.objects.filter(user=request.user, doctor_id=doctor_id).delete()
        if not deleted:
            return Response({"error": "Favorite not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response(status=status.HTTP_204_NO_CONTENT)
