import 'package:run_small_dropbox/src/dropbox_app.dart';
import 'package:test/test.dart';
import 'package:run_small_dropbox/run_small_dropbox.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';

// ignore: invalid_annotation_target
@Timeout(Duration(seconds: 45))
void main() {
  const t = 'sl.BtkhMi4I4OnBGts3EXGXXIZ-MiiFNF_k21Va0PidggLnrtx5_Z8XXnHbo2m2ffHX3HkT55hKrZLER0hKJsma130b-mh5ExiEW2h7yQrnnop_u7H68Rd-_XJE0J0whLE62pVx-rYNJY4KkTY4F2oaPpY';
  DropboxApp app = Dropbox.initializeApp(t);
  DropboxFile dropboxFile = DropboxFile(app);

  group('DropxboxFile Module', () {
    test('copyFile', () async {
      var data = await dropboxFile.copyFile(relocationPath: RelocationPath(fromPath: '/Documents/favicon2_.png', toPath: '/Desktop/favicon2_.png'));

      print(data);

      expect(data['success'], true);
    });
    test('copyBatch', () async {
      List<RelocationPath> entries = [
        RelocationPath(fromPath: '/Documents/drop_up.txt', toPath: '/Desktop/drop_up.txt'),
        RelocationPath(fromPath: '/Documents/uploadtestfile.txt', toPath: '/Desktop/uploadtestfile.txt'),
      ];

      var data = await dropboxFile.copyBatch(entries: entries);

      print(data);

      expect(data['success'], true);
    });
    test('copyBatchCheck', () async {
      var data = await dropboxFile.copyBatchCheck('dbjid:AAAeL_0EYiPPSNJabLJLqdAYWSzDBghRkbYWoV2SDx9Lbg7rr9PG8_Igr_7_irFzWvaVNTeWU7r8lab3cJ9sUOsA');

      print(data);

      expect(data['success'], true);
    });
    test('getCopyReference', () async {
      var data = await dropboxFile.getCopyReference('/Documents/movies.json');

      print(data);

      expect(data['success'], true);
    });
    test('saveCopyReference', () async {
      String copyReference = 'AAAAAlDqCCBkYTZldjZoa3ZiOW0', path = '/Documents/ref/movies.json';
      var data = await dropboxFile.saveCopyReference(copyReference, path);

      print(data);

      expect(data['success'], true);
    });
    test('createFolder', () async {
      var data = await dropboxFile.createFolder('Downloads', autorename: true);

      print(data);

      expect(data['success'], true);
    });
    test('createFolderBatch', () async {
      var data = await dropboxFile.createFolderBatch(
        [
          '/Lib',
        ],
        autorename: false,
        forceAsync: true,
      );

      print(data);

      expect(data['success'], true);
    });
    test('checkCreateFolderBatchJobStatus', () async {
      // For use this method, the flag forceAsync in createFolderBatch must be true
      String asyncJobId = 'dbjid:AACIUTFyJ9SsVq7tFezji8rK-sO4GdpJ2wcn5hOUwsEw71d7hfa2aw_r9SCyiE9rxFqkwvIXmiNo5_KLTY8_LezB';

      var data = await dropboxFile.checkCreateFolderBatchJobStatus(asyncJobId);

      print(data);

      expect(data['success'], true);
    });
    test('deleteFileOrFolder', () async {
      var data = await dropboxFile.deleteFileOrFolder('/Lib');

      print(data);

      expect(data['success'], true);
    });
    test('deleteFilesBatch', () async {
      var data = await dropboxFile.deleteFilesBatch(
        [
          DeleteArg(path: 'Downloads (1)'),
          DeleteArg(path: 'Downloads (2)'),
        ],
      );

      print(data);

      expect(data['success'], true);
    });
    test('deleteBatchCheck', () async {
      String asyncJobId = 'dbjid:AABWTKVCz9BVnnCDelfli-hJO8ve91g7lszKeV7WmycG5kRb5F1X6kTjhYJDTekMK6IDRHZXV7R3UBY417cseFZd';
      var data = await dropboxFile.deleteBatchCheck(asyncJobId);

      print(data);

      expect(data['success'], true);
    });
    test('downloadFile', () async {
      var data = await dropboxFile.downloadFile('/Documents/movies.json');

      if (data['success']) {
        var file = File('C:/Users/Farioso/Desktop/file.json');
        await file.writeAsBytes(utf8.encode(data['result']));
      }

      print(data);

      expect(data['success'], true);
    });
    test('downloadFolderAsZip', () async {
      var data = await dropboxFile.downloadFolderAsZip('/Documents');

      if (data['success']) {
        var file = File('C:/Users/Farioso/Desktop/file.zip');
        await file.writeAsBytes(utf8.encode(data['result']));
      }

      print(data);

      expect(data['success'], true);
    });
    test('exportFile', () async {
      var data = await dropboxFile.exportFile('/Documents/Prime Factorization.xlsx');

      print(data);

      expect(data['error']['error']['.tag'], 'non_exportable');
    });
    test('getFileLockBatch', () async {
      var data = await dropboxFile.getFileLockBatch([]);

      print(data);

      expect(data['success'], true);
    });
    test('getMetadata', () async {
      var data = await dropboxFile.getMetadata('Documents/NãoAmanhãDêOntem.txt');

      print(data);

      expect(data['success'], true);
    });
    test('getPreview', () async {
      var data = await dropboxFile.getPreview('/Documents/mitologiagrega.docx');

      print(data);

      expect(data['success'], true);
    });
    test('getTemporaryLink', () async {
      var data = await dropboxFile.getTemporaryLink('/Documents/drop_up.txt');

      print(data);

      expect(data['success'], true);
    });
    test('getTemporaryUploadLink', () async {
      var data = await dropboxFile.getTemporaryUploadLink('/Documents/favicon2_.png');

      print(data);

      expect(data['success'], true);
    });
    test('getThumbnailV2', () async {
      var data = await dropboxFile.getThumbnailV2('/Documents/favicon2_.png');

      if (data['success']) {
        var file = File('C:/Users/Farioso/Desktop/favicon2_.jpeg');
        await file.writeAsBytes(utf8.encode(data['result']));
      }

      print(data);

      expect(data['success'], true);
    });
    test('getThumbnailBatch', () async {
      var data = await dropboxFile.getThumbnailBatch(['/Documents/favicon2_.png', '/Documents/favicon2_.png']);

      print(data);

      expect(data['success'], true);
    });
    test('listFolder', () async {
      var data = await dropboxFile.listFolder('/Documents');

      print(data);

      expect(data['success'], true);
    });
    test('listFolderContinue', () async {
      String cursor =
          'AAE78DDMQjfST3HwI-9agPpezcTTHtlmD7_UJ57wQnLURQfumAIwhsKp8DI5Xj9KYqvLtZqit8LnkIrRk7z8WvvinYWldfirx-bGJhwUaXSmN9oTjwczXUKl60Jv8_iXf3lhfunPIHoQMJi-sGRXs6QilXo3TcCC9Z4XpAYeXXzbgluZ2STnjWlAh5SGrani41jCXAcjsiOkb-vm6I0gQDCA1sol2wfkuFw08r2K98uT7fydz410rG9weYuIpsdskLljopKsFVeY-ZSvddzgTwqv';
      var data = await dropboxFile.listFolderContinue(cursor);

      print(data);

      expect(data['success'], true);
    });
    test('listFolderGetLatestCursor', () async {
      var data = await dropboxFile.listFolderGetLatestCursor('/Documents');

      print(data);

      expect(data['success'], true);
    });

    test('listFolderLongpoll', () async {
      String cursor =
          'AAGvWI9NjRfdjJwFCJdlQKIbRNnK35-fSUkBNn9f5TetkB217R4nufex4E_Z6l-YUG2MjWs7W5bsubiJVvKbpNHxXHfPYEAUOMIDxoMftdoJfXrofaS9wHSj59cpGV3dYvT-bOcbfdaxqBUkkJ9PhMlRASVSOwt0rFLortlgYLfBMZUd2OiBMI-6hZC2tL_YIhTq-BjTtcqcjFBqpRWmoHvjopBn7d0ULUGORCGB5PtydCg10SIAKg53YPJsstToI5TqM7q28YaZtQjP5Y_A2meX';
      int timeout = 30;
      var data = await dropboxFile.listFolderLongpoll(cursor, timeout: timeout);

      print(data);

      expect(data['success'], true);
    });
    test('listRevisions', () async {
      var data = await dropboxFile.listRevisions('/Documents/mitologiagrega.docx');

      print(data);

      expect(data['success'], true);
    });
    test('lockFileBatch', () async {
      var data = await dropboxFile.lockFileBatch(['/Desktop/movies.json']);

      print(data);

      expect(data['success'], false);
    });
    test('moveV2', () async {
      var data = await dropboxFile.moveV2(RelocationPath(fromPath: '/Documents/users.json', toPath: '/Desktop/users.json'));

      print(data);

      expect(data['success'], true);
    });
    test('moveBatchV2', () async {
      var data = await dropboxFile.moveBatchV2(
        [
          RelocationPath(fromPath: '/Documents/users.json', toPath: '/Desktop/users.json'),
          RelocationPath(fromPath: '/Documents/main.dart', toPath: '/Desktop/main.dart'),
        ],
      );

      print(data);

      expect(data['success'], true);
    });
    test('moveBatchCheckV2', () async {
      String asyncJobId = 'dbjid:AACUbbYLC4V4a58VE3L923XCBH5myG1_qK33mhOjwS5p-7YxylZCpnhcLMlCNCmEA5oQAJMJIYQZkaLee05zMIXW';
      var data = await dropboxFile.moveBatchCheckV2(asyncJobId);

      print(data);

      expect(data['success'], true);
    });
    test('paperCreate', () async {
      var data = await dropboxFile.paperCreate(
        '/Desktop/document.paper',
        importFormat: ImportFormat.html,
      );

      print(data);

      expect(data['success'], true);
    });
    test('paperUpdate', () async {
      var data = await dropboxFile.paperUpdate('');

      print(data);

      expect(data['success'], true);
    });
    test('permanentlyDelete', () async {
      var data = await dropboxFile.permanentlyDelete('/Desktop/movies.json');

      print(data);

      expect(data['success'], false);
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
      var data = await dropboxFile.searchFiles('movies');

      print(data);

      expect(data['success'], true);
    });
    test('searchContinue', () async {
      var data = await dropboxFile.searchContinue('');

      print(data);

      expect(data['success'], true);
    });
    test('addTag', () async {
      var data = await dropboxFile.addTag('/Desktop/movies.json', 'sdkTest');

      print(data);

      expect(data['success'], true);
    });
    test('getTags', () async {
      var data = await dropboxFile.getTags(['/Desktop/movies.json']);

      print(data);

      expect(data['success'], true);
    });
    test('removeTag', () async {
      var data = await dropboxFile.removeTag('/Desktop/movies.json', 'sdkTest');

      print(data);

      expect(data['success'], true);
    });
    test('unlockFileBatch', () async {
      var data = await dropboxFile.unlockFileBatch(['/Desktop/movies.json']);

      print(data);

      expect(data['success'], true);
    });
    test('uploadFile', () async {
      var data = await dropboxFile.uploadFile(
        File('C:/Users/Farioso/Desktop/NãoAmanhãDêOntem.txt'),
        destinationPath: '/Documents/NãoAmanhãDêOntem.txt',
      );

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
      List<UploadSessionFinishArg> entries = [
        UploadSessionFinishArg(
          cursor: UploadSessionCursor(sessionId: '', offset: 0),
          commit: CommitInfo(
            path: '/Homework/math/Matrices.txt',
            mode: WriteMode.add,
            autorename: true,
            clientModified: DateTime.now(),
            mute: false,
            propertyGroups: [
              PropertyGroup(templateId: '', fields: [
                PropertyField(name: 'name', value: 'Bob'),
              ]),
            ],
            strictConflict: false,
            contentHash: 'contentHash123',
          ),
        ),
      ];

      var data = await dropboxFile.uploadSessionFinishBatch(entries);

      print(data);

      expect(data['success'], true);
    });
    test('uploadSessionFinishBatchCheck', () async {
      var data = await dropboxFile.uploadSessionFinishBatchCheck('');

      print(data);

      expect(data['success'], true);
    });
    test('uploadSessionStart', () async {
      var data = await dropboxFile.uploadSessionStart(File(''));

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
