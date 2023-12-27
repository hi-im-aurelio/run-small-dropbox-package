import 'dart:convert';
import 'dart:typed_data';
import 'package:universal_io/io.dart';
import 'package:http/http.dart' as http;

import 'dropbox_app.dart';

/// PathOrLink (union)
/// Information specifying which file to preview. This could be a path to a file, a shared link pointing to a file, or a shared link pointing to a folder, with a relative path.
///
/// `path` - String(pattern="(/(.|[\r\n])*|id:.*)|(rev:[0-9a-f]{9,})|(ns:[0-9]+(/.*)?)")
/// `link` - SharedLinkFileInfo. Consult the Dropbox API docs for details. https://www.dropbox.com/developers/documentation/http/documentation#files-get_thumbnail
enum PathOrLink { path, link }

/// QualityField is only returned for "internal" callers. Quality of the thumbnail image.
///
/// - `quality_80` -  default thumbnail quality.
/// - `quality_90` -  high thumbnail quality.
enum ThumbnailQuality { quality_80, quality_90 }

/// ThumbnailFormat (union)
/// How to resize and crop the image to achieve the desired size.
///
/// `strict`         - Scale down the image to fit within the given size.
/// `bestfit`        - Scale down the image to fit within the given size or its transpose.
/// `fitone_bestfit` - Scale down the image to completely cover the given size or its transpose.
// ignore: constant_identifier_names
enum ThumbnailMode { strict, bestfit, fitone_bestfit }

/// ThumbnailSize (union)
/// ThumbnailSizeThe size for the thumbnail image.
///
/// `w32h32`    -  32 by 32 px.
/// `w64h64`    -  64 by 64 px.
/// `w128h128`  -  128 by 128 px.
/// `w256h256`  -  256 by 256 px.
/// `w480h320`  -  480 by 320 px.
/// `w640h480`  -  640 by 480 px.
/// `w960h640`  -  960 by 640 px.
/// `w1024h768` - 1024 by 768 px.
/// `w2048h1536`- 2048 by 1536 px.
/// `w3200h2400`- Field is only returned for "internal" callers. 3200 by 2400 px.
enum ThumbnailSize {
  w32h32,
  w64h64,
  w128h128,
  w256h256,
  w480h320,
  w640h480,
  w960h640,
  w1024h768,
  w2048h1536,
  w3200h2400,
}

/// ThumbnailFormat (union)
/// The format for the thumbnail image, jpeg (default) or png. For images that are photos, jpeg should be preferred, while png is better for screenshots and digital arts.
enum ThumbnailFormat { jpeg, png }

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

class DropboxFile {
  final DropboxApp _dropbox;

  DropboxFile(DropboxApp dropbox) : _dropbox = dropbox;

  /// Copies a file or folder from one location to another in the user's Dropbox.
  ///
  /// The function uses the Dropbox API endpoint for copying files:
  /// `https://api.dropboxapi.com/2/files/copy_v2`
  ///
  /// Parameters:
  /// - [fromPath]: Path of the file or folder to be copied.
  /// - [toPath]: Destination path in the user's Dropbox.
  /// - [allowOwnershipTransfer]: Allow moves by owner, even if it results in ownership transfer. Default is `false`.
  /// - [allowSharedFolder]: Deprecated. This flag has no effect. Default is `false`.
  /// - [autorename]: Try to autorename the file if there's a conflict. Default is `false`.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'success': true, 'metadata': response body}.
  /// - If there's an error, {'success': false, 'error': response body}.
  ///
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

    final response = await http.post(Uri.parse('https://api.dropboxapi.com/2/files/copy_v2'), headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      return {'success': true, 'metadata': response.body};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Copies multiple files or folders to different locations at once in the user's Dropbox.
  ///
  /// This function utilizes the Dropbox API endpoint for copying multiple files:
  /// `https://api.dropboxapi.com/2/files/copy_batch_v2`
  ///
  /// Parameters:
  /// - [entries]: List of maps, where each map contains the 'from_path' and 'to_path' keys specifying the source and destination paths.
  /// - [autorename]: (Optional) If there's a conflict with any file, attempt to autorename that file to avoid the conflict. Default is `false`.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'success': true, 'result': response body}.
  /// - If there's an error, {'success': false, 'error': response body}.
  ///
  /// Note: This route will either finish synchronously or return a job ID to perform the copy job asynchronously in the background.
  /// Please use `copyBatchCheck` to check the job status.
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

  /// Returns the status of an asynchronous job for copying multiple files or folders.
  ///
  /// This function queries the Dropbox API endpoint for checking the status of a copy batch job:
  /// `https://api.dropboxapi.com/2/files/copy_batch/check_v2`
  ///
  /// Parameters:
  /// - [asyncJobId]: The ID of the asynchronous job. This is the value returned from the method that launched the job.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If the job is still in progress, {'success': true, 'status': 'in_progress'}.
  /// - If the job is complete, {'success': true, 'result': response body}.
  /// - If there's an error or the job doesn't exist, {'success': false, 'error': response body}.
  ///
  /// Note: Use this method to check the status of a copy batch job launched using the `copyBatch` method.
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

  /// Gets a copy reference to a file or folder.
  ///
  /// This function queries the Dropbox API endpoint to obtain a copy reference to a file or folder:
  /// `https://api.dropboxapi.com/2/files/copy_reference/get`
  ///
  /// Parameters:
  /// - [filePath]: The path to the file or folder for which a copy reference is to be obtained.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'success': true, 'result': response body}.
  /// - If there's an error, {'success': false, 'error': response body}.
  ///
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

  /// Save a copy reference returned by `copyReferenceGet` to the user's Dropbox.
  ///
  /// This function utilizes the Dropbox API endpoint for saving a copy reference:
  /// `https://api.dropboxapi.com/2/files/copy_reference/save`
  ///
  /// Parameters:
  /// - [copyReference]: A copy reference returned by `copyReferenceGet`.
  /// - [destinationPath]: Path in the user's Dropbox where the file or folder should be saved.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'success': true, 'result': response body}.
  /// - If there's an error, {'success': false, 'error': response body}.
  ///
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

  /// Create a folder at a given path in the user's Dropbox.
  ///
  /// This function uses the Dropbox API endpoint for creating a folder:
  /// `https://api.dropboxapi.com/2/files/create_folder_v2`
  ///
  /// Parameters:
  /// - [folderPath]: Path in the user's Dropbox to create the folder.
  /// - [autorename]: If there's a conflict, attempt to autorename the folder to avoid the conflict. Default is `false`.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'success': true, 'result': response body}.
  /// - If there's an error, {'success': false, 'error': response body}.
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

  /// Create multiple folders at once in the user's Dropbox.
  ///
  /// This function utilizes the Dropbox API endpoint for creating multiple folders:
  /// `https://api.dropboxapi.com/2/files/create_folder_batch`
  ///
  /// Parameters:
  /// - [folderPaths]: List of paths to be created in the user's Dropbox.
  /// - [autorename]: If there's a conflict, attempt to autorename the folder to avoid the conflict. Default is `false`.
  /// - [forceAsync]: Whether to force the create to happen asynchronously. Default is `false`.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'success': true, 'result': response body}.
  /// - If there's an error, {'success': false, 'error': response body}.
  /// Note: This route is asynchronous for large batches and returns a job ID immediately. Use `createFolderBatchCheck` to check the job status.

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

  /// Returns the status of an asynchronous job for create_folder_batch.
  ///
  /// This function uses the Dropbox API endpoint for checking the status of a create folder batch job:
  /// `https://api.dropboxapi.com/2/files/create_folder_batch/check`
  ///
  /// Parameters:
  /// - [asyncJobId]: Id of the asynchronous job. This is the value of a response returned from the method that launched the job.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If the job is complete, {'status': 'complete', 'entries': response entries}.
  /// - If the job is in progress, {'status': 'in_progress'}.
  /// - If there's an error or another status, {'status': 'other', 'error': response data}.
  ///
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

  /// Delete the file or folder at a given path in the user's Dropbox.
  ///
  /// This function uses the Dropbox API endpoint for deleting a file or folder:
  /// `https://api.dropboxapi.com/2/files/delete_v2`
  ///
  /// Parameters:
  /// - [path]: Path in the user's Dropbox to delete.
  /// - [parentRev]: Perform delete if given "rev" matches the existing file's latest "rev". This field is optional.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'status': 'success', 'metadata': response metadata}.
  /// - If there's an error, {'status': 'error', 'error': response data}.
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

  /// Delete multiple files/folders at once in the user's Dropbox.
  ///
  /// This function uses the Dropbox API endpoint for deleting multiple files:
  /// `https://api.dropboxapi.com/2/files/delete_batch`
  ///
  /// Parameters:
  /// - [paths]: List of paths to be deleted in the user's Dropbox.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If the delete operation is complete, {'status': 'complete', 'entries': response entries}.
  /// - If the delete operation is asynchronous, {'status': 'async', 'async_job_id': response async job id}.
  /// - If there's an error or another status, {'status': 'other', 'error': response data}.
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

  /// Returns the status of an asynchronous job for delete_batch.
  ///
  /// This function uses the Dropbox API endpoint for checking the status of a delete batch job:
  /// `https://api.dropboxapi.com/2/files/delete_batch/check`
  ///
  /// Parameters:
  /// - [asyncJobId]: Id of the asynchronous job. This is the value of a response returned from the method that launched the job.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If the job is complete, {'status': 'complete', 'entries': response entries}.
  /// - If the job is in progress, {'status': 'in_progress'}.
  /// - If there's an error or another status, {'status': 'other', 'error': response data}.
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

  /// Download a file from a user's Dropbox.
  ///
  /// This function uses the Dropbox API endpoint for downloading a file:
  /// `https://content.dropboxapi.com/2/files/download`
  ///
  /// Parameters:
  /// - [path]: The path of the file to download.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'metadata': response metadata, 'file_contents': response file contents as Uint8List}.
  /// - If there's an error, {'status': 'error', 'error': response data}.
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

  /// Download a folder from the user's Dropbox, as a zip file.
  ///
  /// This function uses the Dropbox API endpoint for downloading a folder as a zip file:
  /// `https://content.dropboxapi.com/2/files/download_zip`
  ///
  /// Parameters:
  /// - [path]: The path of the folder to download.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'metadata': response metadata}.
  /// - If there's an error, {'status': 'error', 'error': response data}.
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

  /// Export a file from a user's Dropbox.
  ///
  /// This function uses the Dropbox API endpoint for exporting a file:
  /// `https://content.dropboxapi.com/2/files/export`
  ///
  /// Parameters:
  /// - [path]: The path of the file to be exported.
  /// - [exportFormat]: The file format to which the file should be exported (optional).
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'export_metadata': response export metadata, 'file_metadata': response file metadata}.
  /// - If there's an error, {'status': 'error', 'error': response data}.
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

  /// Return the lock metadata for the given list of paths.
  ///
  /// This function uses the Dropbox API endpoint for getting file lock metadata in batch:
  /// `https://api.dropboxapi.com/2/files/get_file_lock_batch`
  ///
  /// Parameters:
  /// - [paths]: List of paths to get lock metadata for.
  ///
  /// Returns a [Future] with a [List<Map<String, dynamic>>]:
  /// - For each entry in the batch, {'status': 'success', 'lock': entry lock, 'metadata': entry metadata} on success.
  /// - For each entry in the batch, {'status': 'error', 'error': entry error} on error.
  ///
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

  /// Returns the metadata for a file or folder.
  ///
  /// This function uses the Dropbox API endpoint for getting metadata:
  /// `https://api.dropboxapi.com/2/files/get_metadata`
  ///
  /// Parameters:
  /// - [path]: The path of a file or folder on Dropbox.
  /// - [includeDeleted]: Whether to include deleted items in the response (optional).
  /// - [includeHasExplicitSharedMembers]: Whether to include has_explicit_shared_members in the response (optional).
  /// - [includeMediaInfo]: Whether to include mediaInfo in the response (optional).
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If the item is a file, {'type': 'file', 'metadata': response metadata}.
  /// - If the item is a folder, {'type': 'folder', 'metadata': response metadata}.
  /// - If the item is deleted, {'type': 'deleted', 'metadata': response metadata}.
  /// - If the item is unknown, {'type': 'unknown', 'metadata': response metadata}.
  /// - If there's an error, {'type': 'error', 'error': response data}.
  ///
  Future<Map<String, dynamic>> getMetadata(
    String path, {
    bool includeDeleted = false,
    bool includeHasExplicitSharedMembers = false,
    bool includeMediaInfo = false,
  }) async {
    final requestData = {
      'include_deleted': includeDeleted,
      'include_has_explicit_shared_members': includeHasExplicitSharedMembers,
      'include_media_info': includeMediaInfo,
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

  /// Get a preview for a file.
  ///
  /// This function uses the Dropbox API endpoint for getting a file preview:
  /// `https://content.dropboxapi.com/2/files/get_preview`
  ///
  /// Parameters:
  /// - [path]: The path of the file to preview.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'type': 'success', 'metadata': response metadata}.
  /// - If there's an error, {'type': 'error', 'error': response data}.
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

  /// Get a temporary link to stream content of a file.
  ///
  /// This function uses the Dropbox API endpoint for getting a temporary link:
  /// `https://api.dropboxapi.com/2/files/get_temporary_link`
  ///
  /// Parameters:
  /// - [path]: The path to the file you want a temporary link to.
  ///
  /// Returns a [Future] with a [Map<String, dynamic>]:
  /// - If successful, {'type': 'success', 'data': response data}.
  /// - If there's an error, {'type': 'error', 'error': response data}.
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

  /// Get a one-time use temporary upload link to upload a file to a Dropbox location.
  /// This endpoint acts as a delayed upload.
  ///
  /// Readme more in https://www.dropbox.com/developers/documentation/http/documentation#files-get_temporary_upload_link
  ///
  /// Parameters:
  /// - [path]: The path to the file you want a temporary upload link to.
  /// - [autorename]: If true, the returned temporary upload link will have
  ///   an autorename suffix.
  /// - [mode]: The mode of the returned temporary upload link.
  /// - [mute]: If true, no notifications will be sent on changes to this file.
  /// - [strictConflict]: If true, an error will be raised in the case of
  ///   name collision.
  /// - [duration]: The duration of the returned temporary upload link.
  ///
  Future<Map<String, dynamic>> getTemporaryUploadLink(
    String path, {
    bool autorename = true,
    WriteMode mode = WriteMode.add,
    bool mute = false,
    bool strictConflict = false,
    int duration = 3600,
  }) async {
    final commitInfo = {
      'autorename': autorename,
      'mode': mode.name,
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

  /// Get a thumbnail for an image.
  ///
  /// This method supports files with the following file extensions:
  /// jpg, jpeg, png, tiff, tif, gif, webp, ppm, and bmp. Photos larger than 20MB
  /// won't be converted to a thumbnail.
  ///
  /// Example:
  /// ```dart
  /// final result = await getThumbnailV2('/a.docx');
  /// print(result);
  /// ```
  ///
  /// [path]: The path to the image file.
  /// [format]: The format for the thumbnail image, either 'jpeg' (default) or 'png'.
  /// [mode]: How to resize and crop the image to achieve the desired size.
  /// [quality]: Quality of the thumbnail image. Default is 'quality_80'.
  /// [size]: The size for the thumbnail image. Default is 'w64h64'.
  Future<Map<String, dynamic>> getThumbnailV2(
    String path, {
    ThumbnailFormat format = ThumbnailFormat.jpeg,
    ThumbnailMode mode = ThumbnailMode.strict,
    ThumbnailQuality quality = ThumbnailQuality.quality_80,
    ThumbnailSize size = ThumbnailSize.w64h64,
    PathOrLink pathOrLink = PathOrLink.path,
  }) async {
    final requestData = {
      'format': format.name,
      'mode': mode.name,
      'quality': quality.name,
      'resource': {
        '.tag': pathOrLink.name,
        'path': path,
      },
      'size': size.name,
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
