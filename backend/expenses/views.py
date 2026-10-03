from django.contrib.auth import authenticate
from django.db.models import Sum
from rest_framework import generics, permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import AuthToken, Category, Transaction
from .serializers import CategorySerializer, RegisterSerializer, TransactionSerializer


class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        from django.contrib.auth import get_user_model
        return get_user_model().objects.all()


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        username = request.data.get("username", "")
        password = request.data.get("password", "")
        user = authenticate(request, username=username, password=password)
        if user is None:
            return Response({"detail": "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง"}, status=status.HTTP_400_BAD_REQUEST)
        token, _ = AuthToken.objects.get_or_create(user=user)
        return Response({"token": token.key, "username": user.username})


class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = CategorySerializer

    def get_queryset(self):
        queryset = Category.objects.filter(owner=self.request.user)
        kind = self.request.query_params.get("kind")
        if kind in {"income", "expense"}:
            queryset = queryset.filter(kind=kind)
        return queryset

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)


class TransactionViewSet(viewsets.ModelViewSet):
    serializer_class = TransactionSerializer

    def get_queryset(self):
        queryset = Transaction.objects.filter(owner=self.request.user)
        kind = self.request.query_params.get("kind")
        if kind in {"income", "expense"}:
            queryset = queryset.filter(kind=kind)
        return queryset

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    @action(detail=False, methods=["get"])
    def summary(self, request):
        queryset = self.get_queryset()
        income = queryset.filter(kind=Transaction.Kind.INCOME).aggregate(total=Sum("amount"))["total"] or 0
        expense = queryset.filter(kind=Transaction.Kind.EXPENSE).aggregate(total=Sum("amount"))["total"] or 0
        return Response({"income": income, "expense": expense, "balance": income - expense})