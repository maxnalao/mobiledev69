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
        expense_categories = {
            "อาหาร": ("restaurant", "#EF6C00"),
            "เดินทาง": ("directions_bus", "#1565C0"),
            "ช้อปปิ้ง": ("shopping_bag", "#6A1B9A"),
            "ที่พัก": ("home", "#5D4037"),
        }
        income_categories = {
            "เงินเดือน": ("work", "#2E7D32"),
            "งานพิเศษ": ("savings", "#00897B"),
        }
        categories = {}
        for kind, group in ((Category.Kind.EXPENSE, expense_categories), (Category.Kind.INCOME, income_categories)):
            for name, (icon, color) in group.items():
                categories[name], _ = Category.objects.get_or_create(
                    owner=user, name=name, kind=kind, defaults={"icon": icon, "color_hex": color}
                )

        today = date.today()
        income, expense = Transaction.Kind.INCOME, Transaction.Kind.EXPENSE
        # (months ago, day of month or None for today, kind, amount, category, note)
        samples = [
            (0, None, income, 15000, "เงินเดือน", "เงินเดือนประจำเดือน"),
            (0, None, expense, 120, "อาหาร", "ข้าวกลางวัน"),
            (0, 1, expense, 3500, "ที่พัก", "ค่าหอพัก"),
            (0, 1, expense, 85, "อาหาร", "กาแฟ"),
            (1, 1, income, 15000, "เงินเดือน", "เงินเดือนประจำเดือน"),
            (1, 2, expense, 3500, "ที่พัก", "ค่าหอพัก"),
            (1, 8, expense, 1450, "อาหาร", "ค่าอาหารทั้งสัปดาห์"),
            (1, 12, expense, 600, "เดินทาง", "เติมน้ำมัน"),
            (1, 18, income, 2500, "งานพิเศษ", "รับออกแบบโปสเตอร์"),
            (1, 22, expense, 1290, "ช้อปปิ้ง", "รองเท้าผ้าใบ"),
            (2, 1, income, 15000, "เงินเดือน", "เงินเดือนประจำเดือน"),
            (2, 2, expense, 3500, "ที่พัก", "ค่าหอพัก"),
            (2, 10, expense, 1800, "อาหาร", "ค่าอาหารทั้งสัปดาห์"),
            (2, 15, expense, 450, "เดินทาง", "ค่ารถไฟฟ้า"),
            (2, 25, expense, 2390, "ช้อปปิ้ง", "หูฟังบลูทูธ"),
        ]
        for months_ago, day, kind, amount, category, note in samples:
            year, month = today.year, today.month - months_ago
            while month < 1:
                year, month = year - 1, month + 12
            occurred_on = today if day is None else date(year, month, min(day, today.day) if months_ago == 0 else day)
            Transaction.objects.get_or_create(
                owner=user,
                kind=kind,
                amount=amount,
                category=categories[category],
                occurred_on=occurred_on,
                defaults={"note": note},
            )
