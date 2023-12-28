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

    test('Get Copy Reference', () async {
      var data = await dropboxFile.getCopyReference('/Documents/movies.json');

      print(data);

      expect(data['success'], true);
    });

    test('Save Copy Reference', () async {
      // Assuming you have a valid copy reference from a previous test
      var data = await dropboxFile.saveCopyReference(
        copyReference: 'copy_reference_value',
        destinationPath: '/Documents/movies/copied_from_reference.json',
      );

      print(data);

      expect(data['success'], true);
    });

    test('Export File', () async {
      var data = await dropboxFile.exportFile('/Documents/movies.json');

      print(data);

      expect(data['success'], true);
    });

    test('Get File Lock Batch', () async {
      var data = await dropboxFile.getFileLockBatch(['/Documents/movies.json']);

      print(data);

      expect(data['success'], true);
    });

    test('Move File Batch', () async {
      var data = await dropboxFile.moveBatchV2([
        {'from_path': '/Documents/movies.json', 'to_path': '/Documents/movies/movies_moved2.json'},
        {'from_path': '/Documents/movies.json', 'to_path': '/Documents/movies/movies_moved3.json'},
        {'from_path': '/Documents/movies.json', 'to_path': '/Documents/movies/movies_moved4.json'},
      ]);

      print(data);

      expect(data['success'], true);
    });

    test('Move File Batch Check Status', () async {
      var data = await dropboxFile.moveBatchCheckV2('dbjid:AAC9mZf0d0LqyEjsxjyJAbtEWPh5lz375EWng1tZX4Hh9iMZm28SqyaELw04oGxhapZnIh5_uJ6eL0QzuKZ9bU-Z');

      print(data);

      expect(data['success'], true);
    });

    test('List Revisions', () async {
      var data = await dropboxFile.listRevisions('/Documents/movies.json');

      print(data);

      expect(data['success'], true);
    });

    test('Get Metadata', () async {
      var data = await dropboxFile.getMetadata('/Documents/movies.json');

      print(data);

      expect(data['success'], true);
    });

    test('Get Preview', () async {
      var data = await dropboxFile.getPreview('/Documents/movies.json');

      print(data);

      expect(data['success'], true);
    });

    test('Get Thumbnail V2', () async {
      var data = await dropboxFile.getThumbnailV2('/Documents/movies.json');

      print(data);

      expect(data['success'], true);
    });

    test('Get Thumbnail Batch', () async {
      var data = await dropboxFile.getThumbnailBatch(['/Documents/movies.json']);

      print(data);

      expect(data['success'], true);
    });

    test('List Folder', () async {
      var data = await dropboxFile.listFolder('/Documents/movies');

      print(data);

      expect(data['success'], true);
    });

    test('List Folder Continue', () async {
      // Assuming you have a valid cursor from a previous test
      var data = await dropboxFile.listFolderContinue('cursor_value');

      print(data);

      expect(data['success'], true);
    });

    test('List Folder Get Latest Cursor', () async {
      var data = await dropboxFile.listFolderGetLatestCursor('/Documents/movies');

      print(data);

      expect(data['success'], true);
    });

    test('List Folder Longpoll', () async {
      // Assuming you have a valid cursor from a previous test
      var data = await dropboxFile.listFolderLongpoll('cursor_value', timeout: 30);

      print(data);

      expect(data['success'], true);
    });
  });
}
