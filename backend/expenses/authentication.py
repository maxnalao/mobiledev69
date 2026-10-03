from django.utils import timezone
from rest_framework import authentication

from oidc_provider.models import Token
from .models import AuthToken


class OidcTokenAuthentication(authentication.BaseAuthentication):
    """Validates the Bearer access_token issued by django-oidc-provider."""

    keyword = "Bearer"

    def authenticate(self, request):
        auth_header = authentication.get_authorization_header(request).split()
        if not auth_header or auth_header[0].lower() != self.keyword.lower().encode():
            return None
        if len(auth_header) != 2:
            return None

        token_value = auth_header[1].decode()
        try:
            token = Token.objects.get(access_token=token_value)
        except Token.DoesNotExist:
            return None

        if token.expires_at < timezone.now():
            return None

        return (token.user, token)


class BearerTokenAuthentication(authentication.BaseAuthentication):
    """Validates the Bearer token issued by our own /api/login/ endpoint."""

    keyword = "Bearer"

    def authenticate(self, request):
        auth_header = authentication.get_authorization_header(request).split()
        if not auth_header or auth_header[0].lower() != self.keyword.lower().encode():
            return None
        if len(auth_header) != 2:
            return None

        token_value = auth_header[1].decode()
        try:
            token = AuthToken.objects.select_related("user").get(key=token_value)
        except AuthToken.DoesNotExist:
            return None

        return (token.user, token)