import 'dropbox_app.dart' as app;

class Dropbox {
  Dropbox._();

  static Future<app.DropboxApp> initializeApp() async {
    return app.DropboxApp();
  }
}
