import 'package:test/test.dart';
import 'package:run_small_dropbox/run_small_dropbox.dart';

void main() async {
  DropboxApp app = await Dropbox.initializeApp();
  DropboxFile dropboxFile = DropboxFile(app);

  group('DropboxFile Module', () {
    test('Get Temporary Link', () async {
      var data = await dropboxFile.getTemporaryLink('/Documents/movies.json');

      print(data);

      expect(data['success'], true);
    });

    test('Create Folder', () async {
      var data = await dropboxFile.createFolder('/Documents/movies', autorename: true);

      print(data);

      expect(data['success'], true);
    });
  });
}
