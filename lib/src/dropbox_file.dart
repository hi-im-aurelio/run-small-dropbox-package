import 'dart:convert';
import 'dart:typed_data';
import 'package:universal_io/io.dart';
import 'package:http/http.dart' as http;

import 'dropbox_app.dart';

/// WriteMode (union)
/// Your intent when writing a file to some path. This is used to determine what constitutes a conflict and what the autorename strategy is. In some situations, the conflict behavior is identical:
/// (a) If the target path doesn't refer to anything, the file is always written; no conflict.
/// (b) If the target path refers to a folder, it's always a conflict.
/// (c) If the target path refers to a file with identical contents, nothing gets written; no conflict.
/// The conflict checking differs in the case where there's a file at the target path with contents different from the contents you're trying to write.
///
/// `add` - Do not overwrite an existing file if there is a conflict. The autorename strategy is to append a number to the file name. For example, "document.txt" might become "document (2).txt".
///
/// `overwrite` - Always overwrite the existing file. The autorename strategy is the same as it is for add.
///
/// `update` - Overwrite if the given "rev" matches the existing file's "rev". The supplied value should be the latest known "rev" of the file, for example, from FileMetadata, from when the file was last downloaded by the app. This will cause the file on the Dropbox servers to be overwritten if the given "rev" matches the existing file's current "rev" on the Dropbox servers. The autorename strategy is to append the string "conflicted copy" to the file name. For example, "document.txt" might become "document (conflicted copy).txt" or "document (Panda's conflicted copy).txt".
enum WriteMode { add, overwrite, update }

enum DropboxUrlType {
  download(''),
  preview(''),
  getTemporaryLink('https://api.dropboxapi.com/2/files/get_temporary_link'),
  copyV2('https://api.dropboxapi.com/2/files/copy_v2');

  const DropboxUrlType(this.url);

  final String url;
}

class DropboxFile {
  final DropboxApp _dropbox;

  DropboxFile(DropboxApp dropbox) : _dropbox = dropbox;

  Future<Map<String, dynamic>> copyFile({
    required String fromPath,
    required String toPath,
    bool allowOwnershipTransfer = false,
    bool allowSharedFolder = false,
    bool autorename = false,
  }) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {
      'from_path': fromPath,
      'to_path': toPath,
      'allow_ownership_transfer': allowOwnershipTransfer,
      'allow_shared_folder': allowSharedFolder,
      'autorename': autorename,
    };

    final response = await http.post(Uri.parse(DropboxUrlType.copyV2.url), headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      return {'success': true, 'metadata': response.body};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  Future<Map<String, dynamic>> copyBatch({
    required List<Map<String, String>> entries,
    bool autorename = false,
  }) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {
      'autorename': autorename,
      'entries': entries,
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/copy_batch_v2'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  Future<Map<String, dynamic>> copyBatchCheck(String asyncJobId) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {
      'async_job_id': asyncJobId,
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/copy_batch/check_v2'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  Future<Map<String, dynamic>> getCopyReference(String filePath) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {
      'path': filePath,
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/copy_reference/get'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  Future<Map<String, dynamic>> saveCopyReference(String copyReference, String destinationPath) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {
      'copy_reference': copyReference,
      'path': destinationPath,
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/copy_reference/save'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  Future<Map<String, dynamic>> createFolder(String folderPath, {bool autorename = false}) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {
      'path': folderPath,
      'autorename': autorename,
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/create_folder_v2'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  Future<Map<String, dynamic>> createFolderBatch(List<String> folderPaths, {bool autorename = false, bool forceAsync = false}) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {
      'paths': folderPaths,
      'autorename': autorename,
      'force_async': forceAsync,
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/create_folder_batch'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  Future<Map<String, dynamic>> checkCreateFolderBatchJobStatus(String asyncJobId) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {"async_job_id": asyncJobId};

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/create_folder_batch/check'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['.tag'] == 'complete') {
        return {'status': 'complete', 'entries': responseData['entries']};
      } else if (responseData['.tag'] == 'in_progress') {
        return {'status': 'in_progress'};
      } else {
        return {'status': 'other', 'error': responseData};
      }
    } else {
      return {'status': 'error', 'error': response.body};
    }
  }

  Future<Map<String, dynamic>> deleteFileOrFolder(String path, {String parentRev = ""}) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {
      "path": path,
      if (parentRev.isNotEmpty) "parent_rev": parentRev,
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/delete_v2'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {'status': 'success', 'metadata': responseData['metadata']};
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'status': 'error', 'error': errorData};
    }
  }

  Future<Map<String, dynamic>> deleteFilesBatch(List<String> paths) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final entries = paths.map((path) => {"path": path}).toList();
    final body = {"entries": entries};

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/delete_batch'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['.tag'] == 'complete') {
        return {'status': 'complete', 'entries': responseData['entries']};
      } else if (responseData['.tag'] == 'async_job_id') {
        return {'status': 'async', 'async_job_id': responseData['async_job_id']};
      } else {
        return {'status': 'other'};
      }
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'status': 'error', 'error': errorData};
    }
  }

  Future<Map<String, dynamic>> deleteBatchCheck(String asyncJobId) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final body = {'async_job_id': asyncJobId};

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/delete_batch/check'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['.tag'] == 'complete') {
        return {'status': 'complete', 'entries': responseData['entries']};
      } else if (responseData['.tag'] == 'in_progress') {
        return {'status': 'in_progress'};
      } else {
        return {'status': 'other'};
      }
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'status': 'error', 'error': errorData};
    }
  }

  Future<Map<String, dynamic>> downloadFile(String path) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Dropbox-API-Arg': '{"path":"$path"}',
    };

    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/download'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.headers['dropbox-api-result']!);
      final Uint8List fileContents = response.bodyBytes;

      // Pode retornar ou processar os dados conforme necessário
      return {
        'metadata': responseData,
        'file_contents': fileContents,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'status': 'error', 'error': errorData};
    }
  }

  Future<Map<String, dynamic>> downloadFolderAsZip(String path) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Dropbox-API-Arg': '{"path":"$path"}',
    };

    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/download_zip'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.headers['dropbox-api-result']!);

      // Pode retornar ou processar os dados conforme necessário
      return {
        'metadata': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'status': 'error', 'error': errorData};
    }
  }

  Future<Map<String, dynamic>> exportFile(String path, {String? exportFormat}) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Dropbox-API-Arg': '{"path":"$path"}',
    };

    if (exportFormat != null) {
      headers['Dropbox-API-Arg'] = '{"path":"$path","export_format":"$exportFormat"}';
    }

    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/export'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.headers['dropbox-api-result']!);

      // Pode retornar ou processar os dados conforme necessário
      return {
        'export_metadata': responseData['export_metadata'],
        'file_metadata': responseData['file_metadata'],
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {'status': 'error', 'error': errorData};
    }
  }

  Future<List<Map<String, dynamic>>> getFileLockBatch(List<String> paths) async {
    final entries = paths.map((path) => {'path': path}).toList();
    final requestData = {'entries': entries};
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/get_file_lock_batch'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> lockResults = [];

      final List<dynamic> responseData = jsonDecode(response.body)['entries'];
      for (final entry in responseData) {
        if (entry['.tag'] == 'success') {
          final Map<String, dynamic> lockData = {
            'status': 'success',
            'lock': entry['lock'],
            'metadata': entry['metadata'],
          };
          lockResults.add(lockData);
        } else {
          final Map<String, dynamic> errorData = {
            'status': 'error',
            'error': entry['error'],
          };
          lockResults.add(errorData);
        }
      }

      return lockResults;
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return [
        {'status': 'error', 'error': errorData},
      ];
    }
  }

  Future<Map<String, dynamic>> getMetadata(String path) async {
    final requestData = {
      'include_deleted': false,
      'include_has_explicit_shared_members': false,
      'include_media_info': false,
      'path': path,
    };
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/get_metadata'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['.tag'] == 'file') {
        return {
          'type': 'file',
          'metadata': responseData,
        };
      } else if (responseData['.tag'] == 'folder') {
        return {
          'type': 'folder',
          'metadata': responseData,
        };
      } else if (responseData['.tag'] == 'deleted') {
        return {
          'type': 'deleted',
          'metadata': responseData,
        };
      } else {
        return {
          'type': 'unknown',
          'metadata': responseData,
        };
      }
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> getPreview(String path) async {
    final requestData = {
      'path': path,
    };
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Dropbox-API-Arg': jsonEncode(requestData),
    };

    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/get_preview'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'metadata': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> getTemporaryLink(String path) async {
    final requestData = {
      'path': path,
    };
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/get_temporary_link'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> getTemporaryUploadLink(
    String path, {
    bool autorename = true,
    String mode = 'add',
    bool mute = false,
    bool strictConflict = false,
    int duration = 3600,
  }) async {
    final commitInfo = {
      'autorename': autorename,
      'mode': mode,
      'mute': mute,
      'path': path,
      'strict_conflict': strictConflict,
    };

    final requestData = {
      'commit_info': commitInfo,
      'duration': duration.toDouble(),
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/get_temporary_upload_link'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> getThumbnailV2(
    String path, {
    String format = 'jpeg',
    String mode = 'strict',
    String quality = 'quality_80',
    String size = 'w64h64',
  }) async {
    final requestData = {
      'format': format,
      'mode': mode,
      'quality': quality,
      'resource': {
        '.tag': 'path',
        'path': path,
      },
      'size': size,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Dropbox-API-Arg': jsonEncode(requestData),
    };

    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/get_thumbnail_v2'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> getThumbnailBatch(List<String> paths, {String format = 'jpeg', String mode = 'strict', String quality = 'quality_80', String size = 'w64h64'}) async {
    final entries = paths.map((path) {
      return {
        'format': format,
        'mode': mode,
        'quality': quality,
        'size': size,
        'path': path,
      };
    }).toList();

    final requestData = {'entries': entries};

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/get_thumbnail_batch'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> listFolder(String path,
      {bool includeDeleted = false,
      bool includeHasExplicitSharedMembers = false,
      bool includeMediaInfo = false,
      bool includeMountedFolders = true,
      bool includeNonDownloadableFiles = true,
      bool recursive = false,
      int limit = 100}) async {
    final requestData = {
      'path': path,
      'include_deleted': includeDeleted,
      'include_has_explicit_shared_members': includeHasExplicitSharedMembers,
      'include_media_info': includeMediaInfo,
      'include_mounted_folders': includeMountedFolders,
      'include_non_downloadable_files': includeNonDownloadableFiles,
      'recursive': recursive,
      'limit': limit,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/list_folder'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> listFolderContinue(String cursor) async {
    final requestData = {
      'cursor': cursor,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/list_folder/continue'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> listFolderGetLatestCursor(String path) async {
    final requestData = {
      'include_deleted': false,
      'include_has_explicit_shared_members': false,
      'include_media_info': false,
      'include_mounted_folders': true,
      'include_non_downloadable_files': true,
      'path': path,
      'recursive': false,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/list_folder/get_latest_cursor'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> listFolderLongpoll(String cursor, int timeout) async {
    final requestData = {
      'cursor': cursor,
      'timeout': timeout,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://notify.dropboxapi.com/2/files/list_folder/longpoll'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> listRevisions(String path, {int limit = 10, String mode = 'path'}) async {
    final requestData = {
      'limit': limit,
      'mode': mode,
      'path': path,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/list_revisions'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> lockFileBatch(List<String> filePaths) async {
    final requestData = {
      'entries': filePaths.map((path) => {'path': path}).toList(),
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/lock_file_batch'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> moveV2(String fromPath, String toPath, {bool allowOwnershipTransfer = false, bool allowSharedFolder = false, bool autorename = false}) async {
    final requestData = {
      'allow_ownership_transfer': allowOwnershipTransfer,
      'allow_shared_folder': allowSharedFolder, // Deprecated, has no effect
      'autorename': autorename,
      'from_path': fromPath,
      'to_path': toPath,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/move_v2'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> moveBatchV2(List<Map<String, String>> entries, {bool allowOwnershipTransfer = false, bool autorename = false}) async {
    final requestData = {
      'allow_ownership_transfer': allowOwnershipTransfer,
      'autorename': autorename,
      'entries': entries,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/move_batch_v2'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> moveBatchCheckV2(String asyncJobId) async {
    final requestData = {
      'async_job_id': asyncJobId,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/move_batch/check_v2'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> paperCreate(String importFormat, String path, String localFilePath) async {
    final requestData = {
      'import_format': importFormat,
      'path': path,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Dropbox-API-Arg': jsonEncode(requestData),
      'Content-Type': 'application/octet-stream',
    };

    final file = await http.MultipartFile.fromPath('file', localFilePath);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://content.dropboxapi.com/2/files/paper/create'),
    )
      ..headers.addAll(headers)
      ..files.add(file);

    final response = await request.send();

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(await response.stream.bytesToString());
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(await response.stream.bytesToString());
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> paperUpdate(String docUpdatePolicy, String importFormat, int paperRevision, String path, String localFilePath) async {
    final requestData = {
      'doc_update_policy': docUpdatePolicy,
      'import_format': importFormat,
      'paper_revision': paperRevision,
      'path': path,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Dropbox-API-Arg': jsonEncode(requestData),
      'Content-Type': 'application/octet-stream',
    };

    final file = await http.MultipartFile.fromPath('file', localFilePath);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://content.dropboxapi.com/2/files/paper/update'),
    )
      ..headers.addAll(headers)
      ..files.add(file);

    final response = await request.send();

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(await response.stream.bytesToString());
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(await response.stream.bytesToString());
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> permanentlyDelete(String path, {String? parentRev}) async {
    final requestData = {
      'path': path,
      'parent_rev': parentRev,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/permanently_delete'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return {
        'type': 'success',
        'data': {},
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> restoreFile(String path, String rev) async {
    final requestData = {
      'path': path,
      'rev': rev,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/restore'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': data,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> saveUrl(String path, String url) async {
    final requestData = {
      'path': path,
      'url': url,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/save_url'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': data,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> checkJobStatus(String asyncJobId) async {
    final requestData = {
      'async_job_id': asyncJobId,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/save_url/check_job_status'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': data,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> searchFiles(String query, String path) async {
    final requestData = {
      'query': query,
      'options': {
        'file_status': 'active',
        'filename_only': false,
        'max_results': 20,
        'path': path,
      },
      'match_field_options': {
        'include_highlights': false,
      },
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/search_v2'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': data,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> searchContinue(String cursor) async {
    final requestData = {
      'cursor': cursor,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/search/continue_v2'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': data,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> addTag(String filePath, String tagText) async {
    final requestData = {
      'path': filePath,
      'tag_text': tagText,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/tags/add'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return {
        'type': 'success',
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> getTags(List<String> filePaths) async {
    final requestData = {
      'paths': filePaths,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/tags/get'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> removeTag(String filePath, String tagText) async {
    final requestData = {
      'path': filePath,
      'tag_text': tagText,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/tags/remove'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return {
        'type': 'success',
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData,
      };
    }
  }

  Future<Map<String, dynamic>> unlockFileBatch(List<String> filePaths) async {
    final requestData = {
      'entries': filePaths.map((path) => {'path': path}).toList(),
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/unlock_file_batch'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'entries': responseData['entries'],
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData['error'],
      };
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    File file, {
    required String destinationPath,
    WriteMode mode = WriteMode.add,
    bool autorename = false,
    bool mute = false,
    bool strictConflict = false,
  }) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-type': 'application/octet-stream',
      'Dropbox-API-Arg': jsonEncode({
        'path': destinationPath,
        'mode': mode.name,
        'autorename': autorename,
        'mute': mute,
        'strict_conflict': strictConflict,
      }),
    };

    Uint8List data = await file.readAsBytes();
    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/upload'),
      body: data,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'fileMetadata': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData['error'],
      };
    }
  }

  Future<Map<String, dynamic>> uploadSessionAppend(
    File file, {
    required String sessionID,
    required int offset,
    bool close = false,
  }) async {
    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/octet-stream',
      'Dropbox-API-Arg': jsonEncode({
        'close': close,
        'cursor': {
          'offset': offset,
          'session_id': sessionID,
        },
      }),
    };

    Uint8List data = await file.readAsBytes();
    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/upload_session/append_v2'),
      headers: headers,
      body: data,
    );

    if (response.statusCode == 200) {
      return {'type': 'success'};
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData['error'],
      };
    }
  }

  Future<Map<String, dynamic>> uploadSessionFinish(String sessionID, int offset, String path) async {
    final request = http.Request(
      'POST',
      Uri.parse('https://content.dropboxapi.com/2/files/upload_session/finish'),
    )
      ..headers['Authorization'] = 'Bearer ${_dropbox.accessToken}'
      ..headers['Dropbox-API-Arg'] = jsonEncode({
        'commit': {
          'autorename': true,
          'mode': 'add',
          'mute': false,
          'path': path,
          'strict_conflict': false,
        },
        'cursor': {
          'offset': offset,
          'session_id': sessionID,
        },
      })
      ..headers['Content-Type'] = 'application/octet-stream';

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData['error'],
      };
    }
  }

  Future<Map<String, dynamic>> uploadSessionFinishBatch(List<Map<String, dynamic>> entries) async {
    final Uri uri = Uri.parse('https://api.dropboxapi.com/2/files/upload_session/finish_batch_v2');
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestData = {'entries': entries};
    final String requestBody = jsonEncode(requestData);

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData['error'],
      };
    }
  }

  Future<Map<String, dynamic>> uploadSessionFinishBatchCheck(String asyncJobId) async {
    final Uri uri = Uri.parse('https://api.dropboxapi.com/2/files/upload_session/finish_batch/check');
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestData = {'async_job_id': asyncJobId};
    final String requestBody = jsonEncode(requestData);

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['.tag'] == 'complete') {
        return {
          'type': 'complete',
          'data': responseData,
        };
      } else if (responseData['.tag'] == 'in_progress') {
        return {
          'type': 'in_progress',
        };
      } else {
        return {
          'type': 'error',
          'error': responseData['error'],
        };
      }
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData['error'],
      };
    }
  }

  Future<Map<String, dynamic>> uploadSessionStart(String localFilePath) async {
    final Uri uri = Uri.parse('https://content.dropboxapi.com/2/files/upload_session/start');
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/octet-stream',
      'Dropbox-API-Arg': '{"close": false}',
    };

    final File file = File(localFilePath);
    final List<int> fileContent = await file.readAsBytes();

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: fileContent,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData['error'],
      };
    }
  }

  Future<Map<String, dynamic>> uploadSessionStartBatch(int numSessions) async {
    final Uri uri = Uri.parse('https://api.dropboxapi.com/2/files/upload_session/start_batch');
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestBody = {
      'num_sessions': numSessions,
    };

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return {
        'type': 'success',
        'data': responseData,
      };
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return {
        'type': 'error',
        'error': errorData['error'],
      };
    }
  }
}
