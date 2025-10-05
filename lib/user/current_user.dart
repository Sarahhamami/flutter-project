class CurrentUser {
  static final CurrentUser _instance = CurrentUser._internal();
  factory CurrentUser() => _instance;

  CurrentUser._internal();

  Map<String, dynamic>? user;

  void setUser(Map<String, dynamic> u) {
    user = u;
  }

  Map<String, dynamic>? getUser() {
    return user;
  }

  void clear() {
    user = null;
  }
}
