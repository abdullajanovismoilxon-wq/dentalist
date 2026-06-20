from django.urls import path
from .views import MyFavoritesView, AddFavoriteView, RemoveFavoriteView

urlpatterns = [
    path("", MyFavoritesView.as_view(), name="my-favorites"),
    path("add/", AddFavoriteView.as_view(), name="add-favorite"),
    path("remove/<int:doctor_id>/", RemoveFavoriteView.as_view(), name="remove-favorite"),
]
