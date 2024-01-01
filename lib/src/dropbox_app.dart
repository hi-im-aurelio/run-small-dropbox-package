/// Represents an instance of the Dropbox application.
///
/// The `DropboxApp` class encapsulates the access token required for
/// authentication and authorization with the Dropbox API.
class DropboxApp {
  final String _accessToken;

  DropboxApp(String t) : _accessToken = t;

  String get accessToken => _accessToken;
}
