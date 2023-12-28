import 'package:test/test.dart';
import 'package:run_small_dropbox/run_small_dropbox.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';

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

    test('Copy File', () async {
      var data = await dropboxFile.copyFile(fromPath: '/Documents/movies.json', toPath: '/Documents/movies/movies_copy.json');

      print(data);

      expect(data['success'], true);
    });

    test('Copy File Batch', () async {
      var data = await dropboxFile.copyBatch(entries: [
        {'from_path': '/Documents/movies.json', 'to_path': '/Documents/movies/movies_copy2.json'},
        {'from_path': '/Documents/movies.json', 'to_path': '/Documents/movies/movies_copy3.json'},
        {'from_path': '/Documents/movies.json', 'to_path': '/Documents/movies/movies_copy4.json'},
      ]);

      print(data);

      expect(data['success'], true);
    });

    test('Delete File', () async {
      var data = await dropboxFile.deleteFileOrFolder('/Documents/movies');

      print(data);

      expect(data['success'], true);
    });

    test('Delete File Batch', () async {
      var data = await dropboxFile.deleteFilesBatch([
        '/Documents/dev/main.dart',
        '/Documents/dev',
      ]);

      print(data);

      expect(data['success'], true);
    });

    test('Upload File', () async {
      var data = await dropboxFile.uploadFile(File('C:/Users/Farioso/Desktop/dev_ttmp/main.dart'), destinationPath: '/Documents/main.dart');

      print(data);

      expect(data['success'], true);
    });

    test('Upload File Batch', () async {
      var data = await dropboxFile.moveV2('/Documents/main.dart', '/Documents/dev/main.dart');

      print(data);

      expect(data['success'], true);
    });

    test('Delete File Batch Check Status', () async {
      var data = await dropboxFile.deleteBatchCheck('dbjid:AAC9mZf0d0LqyEjsxjyJAbtEWPh5lz375EWng1tZX4Hh9iMZm28SqyaELw04oGxhapZnIh5_uJ6eL0QzuKZ9bU-Z');

      print(data);

      expect(data['success'], true);
    });

    test('Download File', () async {
      var data = await dropboxFile.downloadFile('/Documents/movies.json');

      var file = File('C:/Users/Farioso/Desktop/file.json');
      await file.writeAsBytes(utf8.encode(data['result']));

      print(data);

      expect(data['success'], true);
    });
  });
}
