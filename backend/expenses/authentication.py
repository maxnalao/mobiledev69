from django.utils import timezone
from rest_framework import authentication

from oidc_provider.models import Token


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
            token = Token.objects.select_related("user").get(access_token=token_value)
        except Token.DoesNotExist:
            return None

        if token.expires_at < timezone.now():
            return None

        return (token.user, token)

    def authenticate_header(self, request):
        # Makes DRF answer 401 (not 403) for missing/expired tokens, so the
        # app can tell "session expired" apart from "forbidden".
        return self.keyword
