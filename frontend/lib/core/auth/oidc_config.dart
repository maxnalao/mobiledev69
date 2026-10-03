class OidcConfig {
  static const String issuer = 'http://localhost:8000/openid';
  static const String clientId = '672326';
  static const String redirectUri = 'http://localhost:50000/';
  static const List<String> scopes = ['openid', 'profile', 'email'];
}