import 'package:test/test.dart';
import 'package:run_small_dropbox/run_small_dropbox.dart';

void main() async {
  DropboxApp app = await Dropbox.initializeApp();
  DropboxFile dropboxFile = DropboxFile(app);

  test('Get Temporary Link', () async {
    var data = await dropboxFile.getTemporaryLink('/Moviern/movies.json');

    print(data);

    expect(data['success'], true);
  });
}
