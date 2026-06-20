import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from backend.chat.auth_middleware import JWTAuthMiddleware
from backend.chat.routing import websocket_urlpatterns

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "backend.config.settings")

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
        JWTAuthMiddleware(
            URLRouter(websocket_urlpatterns)
        )
    ),
})
