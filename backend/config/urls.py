from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("openid/", include("oidc_provider.urls", namespace="oidc_provider")),
    path("api/", include("expenses.urls")),
]
