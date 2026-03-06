class AuthValidators {
  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _usernameRe = RegExp(r'^[A-Za-z0-9._-]{3,24}$');

  static bool isValidEmail(String value) {
    return _emailRe.hasMatch(value.trim());
  }

  static bool isValidUsername(String value) {
    return _usernameRe.hasMatch(value.trim());
  }

  static bool isValidPassword(String value) {
    return value.length >= 6;
  }
}
