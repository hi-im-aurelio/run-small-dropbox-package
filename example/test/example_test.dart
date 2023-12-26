import 'package:run_small_dropbox/run_small_dropbox.dart';
import 'package:test/test.dart';

void main() {
  group('Dropbox File', () {
    final dropboxApp = DropboxApp.initializeApp();

    final dropboxFile = DropboxFile(dropboxApp);

    test('Get Temporary Link', () async {
      var data = await dropboxFile.getTemporaryLink('/Moviern/movies.json');
      print(data);

      // expect(data['success'], true);
    });

    test('Copy File', () async {
      final copyResult = await dropboxFile.copyFile(
        fromPath: '/Documents/favicon2_.png',
        toPath: '/Documents/upload/favicon2_copy.png',
        allowOwnershipTransfer: false,
        allowSharedFolder: false,
        autorename: false,
      );

      if (copyResult['success']) {
        print('File copied successfully');
        print(copyResult['metadata']);
      } else {
        print('Error copying file');
        print(copyResult['error']);
      }
    });
  });
}
