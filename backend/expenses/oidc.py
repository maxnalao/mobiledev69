def userinfo(claims, user):
    """Populate the OIDC userinfo response shown after login/consent."""
    claims["name"] = user.get_full_name() or user.username
    claims["preferred_username"] = user.username
    claims["email"] = user.email
    return claims
