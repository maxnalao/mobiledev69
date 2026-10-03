from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import CategoryViewSet, RegisterView, TransactionViewSet

router = DefaultRouter()
router.register("categories", CategoryViewSet, basename="category")
router.register("transactions", TransactionViewSet, basename="transaction")

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
] + router.urls