from django.conf import settings
from django.db import models
import secrets


class Category(models.Model):
    class Kind(models.TextChoices):
        INCOME = "income", "Income"
        EXPENSE = "expense", "Expense"

    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="categories")
    name = models.CharField(max_length=50)
    icon = models.CharField(max_length=30, default="category")
    color_hex = models.CharField(max_length=7, default="#6750A4")
    kind = models.CharField(max_length=7, choices=Kind.choices, default=Kind.EXPENSE)

    class Meta:
        ordering = ["kind", "name"]
        unique_together = ("owner", "name", "kind")

    def __str__(self) -> str:
        return self.name


class Transaction(models.Model):
    class Kind(models.TextChoices):
        INCOME = "income", "Income"
        EXPENSE = "expense", "Expense"

    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="transactions")
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name="transactions")
    kind = models.CharField(max_length=7, choices=Kind.choices)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    note = models.CharField(max_length=255, blank=True)
    occurred_on = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-occurred_on", "-created_at"]

    def __str__(self) -> str:
        return f"{self.kind} {self.amount} ({self.occurred_on})"



def _generate_token_key() -> str:
    # No longer used by any model; kept because migration 0002 references it.
    return secrets.token_hex(20)
