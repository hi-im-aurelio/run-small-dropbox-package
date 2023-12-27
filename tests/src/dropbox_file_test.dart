// test suit

import 'package:test/test.dart';
import 'package:run_small_dropbox/run_small_dropbox.dart';

void main() {
  DropboxApp? app;

  setUpAll(() async => app = await Dropbox.initializeApp());

  test('Get Temporary Link', () {
    print(app?.accessToken);
  });
}
