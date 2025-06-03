class AccountManager {
  static final AccountManager _instance = AccountManager._internal();

  factory AccountManager() => _instance;

  AccountManager._internal();

  String? _username;

  String? get username => _username;

  set username(String? value) {
    _username = value;
  }
}
