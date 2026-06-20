from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="docs"),
    path("api/users/", include("backend.users.urls")),
    path("api/doctors/", include("backend.doctors.urls")),
    path("api/clinics/", include("backend.clinics.urls")),
    path("api/services/", include("backend.services.urls")),
    path("api/schedule/", include("backend.schedule.urls")),
    path("api/appointments/", include("backend.appointments.urls")),
    path("api/appointments/", include("backend.appointments.available_times_urls")),
    path("api/favorites/", include("backend.favorites.urls")),
    path("api/reviews/", include("backend.reviews.urls")),
    path("api/chat/", include("backend.chat.urls")),
    path("api/notifications/", include("backend.notifications.urls")),
    path("api/search/", include("backend.search.urls")),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
