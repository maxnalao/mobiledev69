from datetime import date

from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.core.management.base import BaseCommand
from oidc_provider.models import Client, ResponseType, RSAKey

from expenses.models import Category, Transaction

DEMO_USERNAME = "student01"
DEMO_PASSWORD = "test1234"

# Must match frontend/lib/core/auth/oidc_config.dart and the --web-port in README.
OIDC_CLIENT_ID = "expense-tracker-flutter"
OIDC_REDIRECT_URI = "http://localhost:50000/callback"
OIDC_POST_LOGOUT_REDIRECT_URI = "http://localhost:50000/"


class Command(BaseCommand):
    help = "Create the OIDC client for the Flutter app, the demo user, and sample data."

    def handle(self, *args, **options):
        self._ensure_rsa_key()
        self._ensure_oidc_client()
        user = self._ensure_demo_user()
        self._ensure_sample_data(user)

        self.stdout.write(self.style.SUCCESS(
            f"OIDC client ready -> client_id: {OIDC_CLIENT_ID}  redirect_uri: {OIDC_REDIRECT_URI}"
        ))
        self.stdout.write(self.style.SUCCESS(
            f"Demo user ready   -> username: {DEMO_USERNAME}  password: {DEMO_PASSWORD}"
        ))

    def _ensure_rsa_key(self):
        # Normally created by `manage.py creatersakey`; this is just a safety net.
        if not RSAKey.objects.exists():
            call_command("creatersakey")

    def _ensure_oidc_client(self):
        client, _ = Client.objects.update_or_create(
            client_id=OIDC_CLIENT_ID,
            defaults={
                "name": "Flutter Expense Tracker",
                "client_type": "public",
                "client_secret": "",
                "jwt_alg": "RS256",
                "require_consent": True,
                "reuse_consent": True,
            },
        )
        client.redirect_uris = [OIDC_REDIRECT_URI]
        client.post_logout_redirect_uris = [OIDC_POST_LOGOUT_REDIRECT_URI]
        client.save()
        client.response_types.set([ResponseType.objects.get(value="code")])

    def _ensure_demo_user(self):
        User = get_user_model()
        user, _ = User.objects.get_or_create(
            username=DEMO_USERNAME, defaults={"email": "student01@example.com"}
        )
        user.set_password(DEMO_PASSWORD)
        user.save()
        return user

    def _ensure_sample_data(self, user):
        food, _ = Category.objects.get_or_create(
            owner=user, name="อาหาร", kind=Category.Kind.EXPENSE,
            defaults={"icon": "restaurant", "color_hex": "#EF6C00"},
        )
        salary, _ = Category.objects.get_or_create(
            owner=user, name="เงินเดือน", kind=Category.Kind.INCOME,
            defaults={"icon": "work", "color_hex": "#2E7D32"},
        )

        Transaction.objects.get_or_create(
            owner=user,
            kind=Transaction.Kind.EXPENSE,
            amount=120,
            category=food,
            occurred_on=date.today(),
            defaults={"note": "ข้าวกลางวัน"},
        )
        Transaction.objects.get_or_create(
            owner=user,
            kind=Transaction.Kind.INCOME,
            amount=15000,
            category=salary,
            occurred_on=date.today(),
            defaults={"note": "เงินเดือนประจำเดือน"},
        )
