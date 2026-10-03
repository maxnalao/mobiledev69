/// OIDC settings. These must match the client that
/// `uv run manage.py seed_demo_data` creates in the backend, and the
/// `--web-port 50000` used in README.
class OidcConfig {
  static const String issuer = 'http://localhost:8000/openid';
  static const String clientId = 'expense-tracker-flutter';
  static const String redirectUri = 'http://localhost:50000/callback';
  static const String postLogoutRedirectUri = 'http://localhost:50000/';
  static const List<String> scopes = ['openid', 'profile', 'email'];
}
