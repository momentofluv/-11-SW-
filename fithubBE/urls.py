from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from django.urls import re_path
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from rest_framework_simplejwt.views import (TokenObtainPairView,TokenRefreshView,)

import users
from fithubBE import settings
from users import views


urlpatterns = [
    path('admin/', admin.site.urls),
    path('community/', include('community.urls')),
    path('users/', include('users.urls')),




]
urlpatterns += static(settings.MEDIA_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
