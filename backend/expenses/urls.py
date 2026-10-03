from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import CategoryViewSet, LoginView, RegisterView, TransactionViewSet

router = DefaultRouter()
router.register("categories", CategoryViewSet, basename="category")
router.register("transactions", TransactionViewSet, basename="transaction")

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("login/", LoginView.as_view(), name="login"),
] + router.urls