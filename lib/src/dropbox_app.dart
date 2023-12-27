class DropboxApp {
  DropboxApp._();

  static final DropboxApp _instance = DropboxApp._();

  factory DropboxApp() {
    return _instance;
  }

  String get accessToken => 'YOUR_TOKEN_HERE';
}
