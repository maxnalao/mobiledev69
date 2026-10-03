from django.contrib import admin

from .models import Category, Transaction


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ["name", "owner", "color_hex"]


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ["owner", "kind", "amount", "category", "occurred_on"]
    list_filter = ["kind", "category"]
