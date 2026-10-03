from datetime import date

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand

from expenses.models import Category, Transaction

DEMO_USERNAME = "student01"
DEMO_PASSWORD = "test1234"


class Command(BaseCommand):
    help = "Create the demo OIDC user plus a few sample categories/transactions."

    def handle(self, *args, **options):
        User = get_user_model()
        user, created = User.objects.get_or_create(
            username=DEMO_USERNAME, defaults={"email": "student01@example.com"}
        )
        user.set_password(DEMO_PASSWORD)
        user.is_staff = True
        user.save()

        food, _ = Category.objects.get_or_create(
            owner=user, name="Food", defaults={"icon": "restaurant", "color_hex": "#EF6C00"}
        )
        salary, _ = Category.objects.get_or_create(
            owner=user, name="Salary", defaults={"icon": "work", "color_hex": "#2E7D32"}
        )

        Transaction.objects.get_or_create(
            owner=user,
            kind=Transaction.Kind.EXPENSE,
            amount=120,
            category=food,
            occurred_on=date.today(),
            defaults={"note": "Lunch"},
        )
        Transaction.objects.get_or_create(
            owner=user,
            kind=Transaction.Kind.INCOME,
            amount=15000,
            category=salary,
            occurred_on=date.today(),
            defaults={"note": "Monthly salary"},
        )

        self.stdout.write(self.style.SUCCESS(
            f"Demo user ready -> username: {DEMO_USERNAME}  password: {DEMO_PASSWORD}"
        ))
