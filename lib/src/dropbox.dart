import 'dropbox_app.dart' as app;

/// **Dropbox SDK**
///
/// A Dart SDK for interacting with the Dropbox API.
///
/// This SDK provides functionality for initializing a Dropbox app and interacting
/// with the Dropbox API for file-related operations. It is designed to resemble
/// the structure of other popular SDKs, such as the Firebase SDK for Flutter.
///
/// Example:
/// ```dart
/// // Initialize the Dropbox app
/// var dropboxApp = Dropbox.initializeApp();
///
/// // Use the Dropbox app for file operations
/// var file = DropboxFile(dropboxApp);
/// var result = await file.listFolder('/Documents');
/// print(result);
/// ```
class Dropbox {
  Dropbox._();

  static app.DropboxApp initializeApp(String accessToken) {
    return app.DropboxApp(accessToken);
  }
}
