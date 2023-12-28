import 'package:test/test.dart';
import 'package:run_small_dropbox/run_small_dropbox.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';

void main() async {
  DropboxApp app = await Dropbox.initializeApp();
  DropboxFile dropboxFile = DropboxFile(app);

  group('DropxboxFile Module', () {
    test('copyFile', () async {
      var data = await dropboxFile.copyFile(fromPath: '/Documents/movies.json', toPath: '/Documents/movies/movies_copy.json');

      print(data);

      expect(data['success'], true);
    });
    test('copyBatch', () async {
      var data = await dropboxFile.copyBatch(entries: [
        {'from_path': '/Documents/movies.json', 'to_path': '/Documents/movies/movies_copy2.json'},
        {'from_path': '/Documents/movies.json', 'to_path': '/Documents/movies/movies_copy3.json'},
        {'from_path': '/Documents/movies.json', 'to_path': '/Documents/movies/movies_copy4.json'},
      ]);

      print(data);

      expect(data['success'], true);
    });
    test('copyBatchCheck', () async {
      var data = await dropboxFile.copyBatchCheck('');

      print(data);

      expect(data['success'], true);
    });
    test('getCopyReference', () async {
      var data = await dropboxFile.getCopyReference('');

      print(data);

      expect(data['success'], true);
    });
    test('saveCopyReference', () async {
      var data = await dropboxFile.saveCopyReference('', '');

      print(data);

      expect(data['success'], true);
    });
    test('createFolder', () async {
      var data = await dropboxFile.createFolder('');

      print(data);

      expect(data['success'], true);
    });
    test('createFolderBatch', () async {
      var data = await dropboxFile.createFolderBatch([]);

      print(data);

      expect(data['success'], true);
    });
    test('checkCreateFolderBatchJobStatus', () async {
      var data = await dropboxFile.checkCreateFolderBatchJobStatus('');

      print(data);

      expect(data['success'], true);
    });
    test('deleteFileOrFolder', () async {
      var data = await dropboxFile.deleteFileOrFolder('/Documents/movies');

      print(data);

      expect(data['success'], true);
    });
    test('deleteFilesBatch', () async {
      var data = await dropboxFile.deleteFilesBatch([
        '/Documents/dev/main.dart',
        '/Documents/dev',
      ]);

      print(data);

      expect(data['success'], true);
    });
    test('deleteBatchCheck', () async {
      var data = await dropboxFile.deleteBatchCheck('dbjid:AAC9mZf0d0LqyEjsxjyJAbtEWPh5lz375EWng1tZX4Hh9iMZm28SqyaELw04oGxhapZnIh5_uJ6eL0QzuKZ9bU-Z');

      print(data);

      expect(data['success'], true);
    });
    test('downloadFile', () async {
      var data = await dropboxFile.downloadFile('/Documents/movies.json');

      var file = File('C:/Users/Farioso/Desktop/file.json');
      await file.writeAsBytes(utf8.encode(data['result']));

      print(data);

      expect(data['success'], true);
    });
    test('downloadFolderAsZip', () async {
      var data = await dropboxFile.downloadFolderAsZip('');

      print(data);

      expect(data['success'], true);
    });
    test('exportFile', () async {
      var data = await dropboxFile.exportFile('');

      print(data);

      expect(data['success'], true);
    });
    test('getFileLockBatch', () async {
      var data = await dropboxFile.getFileLockBatch([]);

      print(data);

      expect(data['success'], true);
    });
    test('getMetadata', () async {
      var data = await dropboxFile.getMetadata('');

      print(data);

      expect(data['success'], true);
    });
    test('getPreview', () async {
      var data = await dropboxFile.getPreview('');

      print(data);

      expect(data['success'], true);
    });
    test('getTemporaryLink', () async {
      var data = await dropboxFile.getTemporaryLink('');

      print(data);

      expect(data['success'], true);
    });
    test('getTemporaryUploadLink', () async {
      var data = await dropboxFile.getTemporaryUploadLink('');

      print(data);

      expect(data['success'], true);
    });
    test('getThumbnailV2', () async {
      var data = await dropboxFile.getThumbnailV2('');

      print(data);

      expect(data['success'], true);
    });
    test('getThumbnailBatch', () async {
      var data = await dropboxFile.getThumbnailBatch([]);

      print(data);

      expect(data['success'], true);
    });
    test('listFolder', () async {
      var data = await dropboxFile.listFolder('');

      print(data);

      expect(data['success'], true);
    });
    test('listFolderContinue', () async {
      var data = await dropboxFile.listFolderContinue('');

      print(data);

      expect(data['success'], true);
    });
    test('listFolderGetLatestCursor', () async {
      var data = await dropboxFile.listFolderGetLatestCursor('');

      print(data);

      expect(data['success'], true);
    });
    test('listFolderLongpoll', () async {
      var data = await dropboxFile.listFolderLongpoll('');

      print(data);

      expect(data['success'], true);
    });
    test('listRevisions', () async {
      var data = await dropboxFile.listRevisions('');

      print(data);

      expect(data['success'], true);
    });
    test('lockFileBatch', () async {
      var data = await dropboxFile.lockFileBatch([]);

      print(data);

      expect(data['success'], true);
    });
    test('moveV2', () async {
      var data = await dropboxFile.moveV2('/Documents/main.dart', '/Documents/dev/main.dart');

      print(data);

      expect(data['success'], true);
    });
    test('moveBatchV2', () async {
      var data = await dropboxFile.moveBatchV2([]);

      print(data);

      expect(data['success'], true);
    });
    test('moveBatchCheckV2', () async {
      var data = await dropboxFile.moveBatchCheckV2('');

      print(data);

      expect(data['success'], true);
    });
    test('paperCreate', () async {
      var data = await dropboxFile.paperCreate('');

      print(data);

      expect(data['success'], true);
    });
    test('paperUpdate', () async {
      var data = await dropboxFile.paperUpdate('');

      print(data);

      expect(data['success'], true);
    });
    test('permanentlyDelete', () async {
      var data = await dropboxFile.permanentlyDelete('');

      print(data);

      expect(data['success'], true);
    });
    test('restoreFile', () async {
      var data = await dropboxFile.restoreFile('', '');

      print(data);

      expect(data['success'], true);
    });
    test('saveUrl', () async {
      var data = await dropboxFile.saveUrl('', '');

      print(data);

      expect(data['success'], true);
    });
    test('checkJobStatus', () async {
      var data = await dropboxFile.checkJobStatus('');

      print(data);

      expect(data['success'], true);
    });
    test('searchFiles', () async {
      var data = await dropboxFile.searchFiles('', path: '');

      print(data);

      expect(data['success'], true);
    });
    test('searchContinue', () async {
      var data = await dropboxFile.searchContinue('');

      print(data);

      expect(data['success'], true);
    });
    test('addTag', () async {
      var data = await dropboxFile.addTag('', '');

      print(data);

      expect(data['success'], true);
    });
    test('getTags', () async {
      var data = await dropboxFile.getTags([]);

      print(data);

      expect(data['success'], true);
    });
    test('removeTag', () async {
      var data = await dropboxFile.removeTag('', '');

      print(data);

      expect(data['success'], true);
    });
    test('unlockFileBatch', () async {
      var data = await dropboxFile.unlockFileBatch([]);

      print(data);

      expect(data['success'], true);
    });
    test('uploadFile', () async {
      var data = await dropboxFile.uploadFile(File('C:/Users/Farioso/Desktop/dev_ttmp/main.dart'), destinationPath: '/Documents/main.dart');

      print(data);

      expect(data['success'], true);
    });
    test('uploadSessionAppend', () async {
      var data = await dropboxFile.uploadSessionAppend(File(''), sessionID: '', offset: 3);

      print(data);

      expect(data['success'], true);
    });
    test('uploadSessionFinish', () async {
      var data = await dropboxFile.uploadSessionFinish('', 0, '');

      print(data);

      expect(data['success'], true);
    });
    test('uploadSessionFinishBatch', () async {
      var data = await dropboxFile.uploadSessionFinishBatch([]);

      print(data);

      expect(data['success'], true);
    });
    test('uploadSessionFinishBatchCheck', () async {
      var data = await dropboxFile.uploadSessionFinishBatchCheck('');

      print(data);

      expect(data['success'], true);
    });
    test('uploadSessionStart', () async {
      var data = await dropboxFile.uploadSessionStart('');

      print(data);

      expect(data['success'], true);
    });
    test('uploadSessionStartBatch', () async {
      var data = await dropboxFile.uploadSessionStartBatch(0);

      print(data);

      expect(data['success'], true);
    });
  });
}
