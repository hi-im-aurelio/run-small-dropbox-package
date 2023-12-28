import 'dart:convert';
import 'dart:typed_data';
import 'package:universal_io/io.dart';
import 'package:http/http.dart' as http;

import 'dropbox_app.dart';

/// PaperDocUpdatePolicy (open union)
///
/// How the provided content should be applied to the doc.
///
/// `update` - Sets the doc content to the provided content if the provided paper_revision matches the latest doc revision. Otherwise, returns an error.
/// `overwrite` - Sets the doc content to the provided content without checking paper_revision.
/// `prepend` - Adds the provided content to the beginning of the doc without checking paper_revision.
/// `append` - Adds the provided content to the end of the doc without checking paper_revision.
enum PaperDocUpdatePolicy { update, overwrite, prepend, append }

/// ImportFormat (union)
///
/// The import format of the incoming Paper doc content.
///
/// `html` - The provided data is interpreted as standard HTML.
/// `markdown` - The provided data is interpreted as markdown.
/// `plain_text` - The provided data is interpreted as plain text.
// ignore: constant_identifier_names
enum ImportFormat { markdown, html, plain_text }

/// FileStatus (union)
///
/// Restricts search to the given file status
///
/// `active` - The file or folder is active.
/// `deleted` - The file or folder was deleted.
enum FileStatus { active, deleted }

/// PathOrLink (union)
/// Information specifying which file to preview. This could be a path to a file, a shared link pointing to a file, or a shared link pointing to a folder, with a relative path.
///
/// `path` - String(pattern="(/(.|[\r\n])*|id:.*)|(rev:[0-9a-f]{9,})|(ns:[0-9]+(/.*)?)")
/// `link` - SharedLinkFileInfo.
///
/// Consult the Dropbox API docs for details. https://www.dropbox.com/developers/documentation/http/documentation#files-get_thumbnail
enum PathOrLink { path, link }

/// ThumbnailQuality is only returned for "internal" callers. Quality of the thumbnail image.
///
/// - `quality_80` -  default thumbnail quality.
/// - `quality_90` -  high thumbnail quality.
enum ThumbnailQuality { quality_80, quality_90 }

/// ThumbnailMode (union)
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
/// For images that are photos, jpeg should be preferred, while png is better for screenshots and digital arts.
enum ThumbnailFormat { jpeg, png, jpg, tiff, tif, gif, webp, ppm, bmp }

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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
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
      return {'success': true, 'result': response.body};
    } else {
      return {'success': false, 'error': response.body};
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
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
  Future<Map<String, dynamic>> getFileLockBatch(List<String> paths) async {
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Returns the metadata for a file or folder.
  ///
  /// This function uses the Dropbox API endpoint for getting metadata:
  /// `https://api.dropboxapi.com/2/files/get_metadata`
  ///
  /// Parameters:
  /// - `path`: The path of a file or folder on Dropbox.
  ///
  /// - `includeDeleted`: Whether to include deleted items in the response (optional).
  ///
  /// - `includeHasExplicitSharedMembers`: Whether to include has_explicit_shared_members in the response (optional).
  ///
  /// - `includeMediaInfo`: Whether to include mediaInfo in the response (optional).
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Get a thumbnail for an image.
  ///
  /// Photos larger than 20MB won't be converted to a thumbnail.
  ///
  /// This method supports files with the following file extensions:
  ///
  /// - `jpg`
  /// - `jpeg`
  /// - `png`
  /// - `tiff`
  /// - `tif`
  /// - `gif`
  /// - `webp`
  /// - `ppm`
  /// - `bmp`
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Get thumbnails for a list of images.
  ///
  /// Photos larger than 20MB won't be converted to a thumbnail.
  ///
  /// This method supports files with the following file extensions:
  ///
  /// - `jpg`
  /// - `jpeg`
  /// - `png`
  /// - `tiff`
  /// - `tif`
  /// - `gif`
  /// - `webp`
  /// - `ppm`
  /// - `bmp`
  Future<Map<String, dynamic>> getThumbnailBatch(
    List<String> paths, {
    ThumbnailFormat format = ThumbnailFormat.jpeg,
    ThumbnailMode mode = ThumbnailMode.strict,
    ThumbnailQuality quality = ThumbnailQuality.quality_80,
    ThumbnailSize size = ThumbnailSize.w64h64,
  }) async {
    final entries = paths.map((path) {
      return {
        'format': format.name,
        'mode': mode.name,
        'quality': quality.name,
        'size': size.name,
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Starts returning the contents of a folder.
  ///
  /// If the result's ListFolderResult.has_more field is true, call list_folder/continue
  /// with the returned ListFolderResult.cursor to retrieve more entries.
  ///
  /// Note: auth.RateLimitError may be returned if multiple list_folder or list_folder/continue
  /// calls with the same parameters are made simultaneously by the same API app for the same user.
  ///
  /// `path`: A unique identifier for the file.
  ///
  /// `includeDeleted`: If true, the results will include entries for files and folders that used to exist but were deleted.
  ///
  /// `includeHasExplicitSharedMembers`: If true, the results will include a flag for each file indicating whether or not that file has any explicit members.
  ///
  /// `includeMediaInfo`: Deprecated. If true, FileMetadata.media_info is set for photo and video.
  ///
  /// `includeMountedFolders`: If true, the results will include entries under mounted folders, which include the app folder, shared folder, and team folder.
  ///
  /// `includeNonDownloadableFiles`: If true, include files that are not downloadable, i.e., Google Docs. Default is true.
  ///
  /// `recursive`: If true, the list folder operation will be applied recursively to all subfolders.
  ///
  /// `limit`: The maximum number of results to return per request. This is an approximate number.
  Future<Map<String, dynamic>> listFolder(
    String path, {
    bool includeDeleted = false,
    bool includeHasExplicitSharedMembers = false,
    bool includeMediaInfo = false,
    bool includeMountedFolders = true,
    bool includeNonDownloadableFiles = true,
    bool recursive = false,
    int limit = 100,
  }) async {
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Continues retrieving the contents of a folder.
  ///
  /// `cursor`: The cursor returned by your last call to `listFolder` or `listFolderContinue`.
  /// A way to quickly get a cursor for the folder's state.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// A way to quickly get a cursor for the folder's state.
  ///
  /// Unlike `listFolder`, `listFolderGetLatestCursor` doesn't return any entries.
  ///
  /// This endpoint is for an app that only needs to know about new files and modifications
  /// and doesn't need to know about files that already exist in Dropbox.
  ///
  /// `path`: A unique identifier for the file.
  ///
  /// `includeDeleted`: If true, the results will include entries for files and folders that used to exist but were deleted.
  ///
  /// `includeHasExplicitSharedMembers`: If true, the results will include a flag for each file indicating whether or not that file has any explicit members.
  ///
  /// `includeMediaInfo`: Deprecated. If true, FileMetadata.media_info is set for photo and video.
  ///
  /// `includeMountedFolders`: If true, the results will include entries under mounted folders, which include the app folder, shared folder, and team folder.
  ///
  /// `includeNonDownloadableFiles`: If true, include files that are not downloadable, i.e., Google Docs. Default is true.
  ///
  /// `recursive`: If true, the list folder operation will be applied recursively to all subfolders.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// A longpoll endpoint to wait for changes on an account. In conjunction with
  /// listFolder/continue, this call gives you a low-latency way to monitor an
  /// account for file changes. The connection will block until there are changes
  /// available or a timeout occurs. This endpoint is useful mostly for
  /// client-side apps. If you're looking for server-side notifications, check
  /// out our webhooks documentation.
  ///
  /// `cursor`: A cursor as returned by list_folder or list_folder/continue.
  /// Cursors retrieved by setting ListFolderArg.include_media_info to true are
  /// not supported.
  ///
  /// `timeout`: A timeout in seconds. The request will block for at most this
  /// length of time, plus up to 90 seconds of random jitter added to avoid the
  /// thundering herd problem. Care should be taken when using this parameter,
  /// as some network infrastructure does not support long timeouts. The default
  /// for this field is 30.
  Future<Map<String, dynamic>> listFolderLongpoll(String cursor, {int timeout = 30}) async {
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Returns revisions for files based on a file path or a file id. The file
  /// path or file id is identified from the latest file entry at the given
  /// file path or id. This endpoint allows your app to query either by file
  /// path or file id by setting the mode parameter appropriately. In the
  /// ListRevisionsMode.path (default) mode, all revisions at the same file
  /// path as the latest file entry are returned. If revisions with the same
  /// file id are desired, then mode must be set to ListRevisionsMode.id. The
  /// ListRevisionsMode.id mode is useful to retrieve revisions for a given
  /// file across moves or renames.
  ///
  /// `path`: The path to the file.
  ///
  /// `limit`: The maximum number of revisions to return (default is 10).
  ///
  /// `mode`: The mode to determine whether to query by path or file id.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Lock the files at the given paths. A locked file will be writable only
  /// by the lock holder. A successful response indicates that the file has
  /// been locked. Returns a list of the locked file paths and their metadata
  /// after this operation.
  ///
  /// This endpoint does not support apps with the app folder permission.
  ///
  /// `filePaths`: List of file paths to lock.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Move a file or folder to a different location in the user's Dropbox. If
  /// the source path is a folder all its contents will be moved. Note that
  /// we do not currently support case-only renaming.
  ///
  /// `fromPath`: Path in the user's Dropbox to be copied or moved.
  ///
  /// `toPath`: Path in the user's Dropbox that is the destination.
  ///
  /// `allowOwnershipTransfer`: Allow moves by owner even if it would result
  /// in an ownership transfer for the content being moved. This does not apply
  /// to copies. The default for this field is False.
  ///
  /// `allowSharedFolder`: Deprecated. This flag has no effect. The default for
  /// this field is False.
  ///
  /// `autorename`: If there's a conflict, have the Dropbox server try to
  /// autorename the file to avoid the conflict. The default for this field is False.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Move multiple files or folders to different locations at once in the user's
  /// Dropbox. Note that we do not currently support case-only renaming. This route
  /// will replace move_batch:1. The main difference is this route will return
  /// status for each entry, while move_batch:1 raises failure if any entry fails.
  /// This route will either finish synchronously, or return a job ID and do the
  /// async move job in the background. Please use move_batch/check:2 to check
  /// the job status.
  ///
  /// `entries`: List of entries to be moved or copied. Each entry is RelocationPath.
  ///
  /// `allowOwnershipTransfer`: Allow moves by owner even if it would result
  /// in an ownership transfer for the content being moved. This does not apply
  /// to copies. The default for this field is False.
  ///
  /// `autorename`: If there's a conflict with any file, have the Dropbox server
  /// try to autorename that file to avoid the conflict. The default for this
  /// field is False.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Returns the status of an asynchronous job for move_batch:2. It returns a list
  /// of results for each entry.
  ///
  /// `asyncJobId`: Id of the asynchronous job. This is the value of a response
  /// returned from the method that launched the job.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Creates a new Paper doc with the provided content.
  ///
  /// This endpoint does not support apps with the app folder permission.
  ///
  /// `importFormat`: The format of the provided data.
  ///
  /// `path`: The fully qualified path to the location in the user's Dropbox
  /// where the Paper Doc should be created. This should include the document's
  /// title and end with .paper.
  Future<Map<String, dynamic>> paperCreate(
    String path, {
    ImportFormat importFormat = ImportFormat.markdown,
  }) async {
    final requestData = {
      'import_format': importFormat.name,
      'path': path,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Dropbox-API-Arg': jsonEncode(requestData),
      'Content-Type': 'application/octet-stream',
    };

    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/paper/create'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Updates an existing Paper doc with the provided content.
  ///
  /// This endpoint does not support apps with the app folder permission.
  ///
  /// `docUpdatePolicy`: How the provided content should be applied to the doc.
  ///
  /// `importFormat`: The format of the provided data.
  ///
  /// `paperRevision`: The latest doc revision. Required when docUpdatePolicy is
  /// update. This value must match the current revision of the doc or error
  /// revision_mismatch will be returned. This field is optional.
  ///
  /// `path`: Path in the user's Dropbox to update. The path must correspond to
  /// a Paper doc or an error will be returned.
  Future<Map<String, dynamic>> paperUpdate(
    String path, {
    PaperDocUpdatePolicy docUpdatePolicy = PaperDocUpdatePolicy.update,
    ImportFormat importFormat = ImportFormat.markdown,
    int paperRevision = 0,
  }) async {
    final requestData = {
      'doc_update_policy': docUpdatePolicy.name,
      'import_format': importFormat.name,
      'paper_revision': paperRevision,
      'path': path,
    };

    final headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Dropbox-API-Arg': jsonEncode(requestData),
      'Content-Type': 'application/octet-stream',
    };

    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/paper/update'),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Permanently delete the file or folder at a given path.
  ///
  /// `path`: Path in the user's Dropbox to delete.
  ///
  /// `parentRev`: Perform delete if given "rev" matches the existing file's
  /// latest "rev". This field does not support deleting a folder. This field is optional.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Restore a specific revision of a file to the given path.
  ///
  /// `path`: The path to the file.
  /// `rev`: The revision of the file to restore.
  ///
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Save the data from a specified URL into a file in the user's Dropbox.
  /// Note that the transfer from the URL must complete within 15 minutes,
  /// or the operation will time out, and the job will fail. If the given path
  /// already exists, the file will be renamed to avoid the conflict (e.g., myfile (1).txt).
  ///
  /// `path`]: The path in the user's Dropbox where the file should be saved.
  /// `url`]: The URL from which to save the file.
  ///
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Check the status of a save_url job.
  ///
  /// `asyncJobId`: The asynchronous job ID returned by the save_url operation.
  ///
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Searches for files and folders.
  ///
  /// `query`: The search query.
  /// `path`: The path to search within.
  Future<Map<String, dynamic>> searchFiles(
    String query, {
    required String path,
    bool includeHighlights = false,
    bool filenameOnly = false,
    int maxResults = 10,
    FileStatus fileStatus = FileStatus.active,
  }) async {
    final requestData = {
      'query': query,
      'options': {
        'file_status': fileStatus.name,
        'filename_only': filenameOnly,
        'max_results': maxResults,
        'path': path,
      },
      'match_field_options': {
        'include_highlights': includeHighlights,
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Fetches the next page of search results returned from search:2.
  ///
  /// `cursor`: The cursor from the previous search response.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Add a tag to an item. A tag is a string.
  ///
  /// `filePath`: The path to the item.
  /// `tagText`: The tag text to add.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Get a list of tags assigned to items.
  ///
  /// `filePaths`: List of file paths to get tags for.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Remove a tag from an item.
  ///
  /// `filePath`: The path to the item.
  /// `tagText`: The tag text to remove.
  ///
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Unlock the files at the given paths. A locked file can only be unlocked by the
  /// lock holder or, if a business account, a team admin. A successful response
  /// indicates that the file has been unlocked. Returns a list of the unlocked file
  /// paths and their metadata after this operation.
  ///
  /// This endpoint does not support apps with the app folder permission.
  ///
  /// `filePaths`: List of file paths to unlock.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Create a new file with the contents provided in the request. Do not use this
  /// to upload a file larger than 150 MB. Instead, create an upload session with
  /// upload_session/start. Calls to this endpoint will count as data transport calls
  /// for any Dropbox Business teams with a limit on the number of data transport
  /// calls allowed per month. For more information, see the Data transport limit page.
  ///
  /// `file`: The file to be uploaded.
  ///
  /// `destinationPath`: The path in the user's Dropbox where the file should be created.
  ///
  /// `mode`: The write mode for the file.
  ///
  /// `autorename`: If there's a conflict, have the Dropbox server try to autorename the file.
  ///
  /// `mute`: Whether to mute notifications.
  ///
  /// `strictConflict`: Whether to enforce strict conflict checking.
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
        "autorename": autorename,
        "mode": mode.name,
        "mute": mute,
        "path": destinationPath,
        "strict_conflict": strictConflict,
      }),
    };

    Uint8List data = await file.readAsBytes();
    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/upload'),
      body: data,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Append more data to an upload session. When the parameter close is set, this
  /// call will close the session. A single request should not upload more than 150 MB.
  /// The maximum size of a file one can upload to an upload session is 350 GB.
  /// Calls to this endpoint will count as data transport calls for any Dropbox Business
  /// teams with a limit on the number of data transport calls allowed per month.
  /// For more information, see the Data transport limit page.
  ///
  /// `file`: The file to be appended.
  ///
  /// `sessionID`: The ID of the upload session.
  ///
  /// `offset`: The byte offset at which the data should be appended.
  ///
  /// `close`: Whether to close the session after appending the data.
  ///
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Finish an upload session and save the uploaded data to the given file path.
  /// A single request should not upload more than 150 MB. The maximum size of a file
  /// one can upload to an upload session is 350 GB. Calls to this endpoint will count
  /// as data transport calls for any Dropbox Business teams with a limit on the number
  /// of data transport calls allowed per month. For more information, see the Data transport limit page.
  ///
  /// `sessionID`: The ID of the upload session.
  ///
  /// `offset`: The byte offset at which the data should be saved.
  ///
  /// `path`: The path in the user's Dropbox where the file should be saved.
  ///
  Future<Map<String, dynamic>> uploadSessionFinish(
    String sessionID,
    int offset,
    String path, {
    bool autorename = false,
    bool mute = false,
    bool strictConflict = false,
    WriteMode mode = WriteMode.add,
  }) async {
    final request = http.Request(
      'POST',
      Uri.parse('https://content.dropboxapi.com/2/files/upload_session/finish'),
    )
      ..headers['Authorization'] = 'Bearer ${_dropbox.accessToken}'
      ..headers['Dropbox-API-Arg'] = jsonEncode({
        'commit': {
          'autorename': autorename,
          'mode': mode.name,
          'mute': mute,
          'path': path,
          'strict_conflict': strictConflict,
        },
        'cursor': {
          'offset': offset,
          'session_id': sessionID,
        },
      })
      ..headers['Content-Type'] = 'application/octet-stream';

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// This route helps you commit many files at once into a user's Dropbox. Use
  /// upload_session/start and upload_session/append:2 to upload file contents.
  /// We recommend uploading many files in parallel to increase throughput.
  /// Once the file contents have been uploaded, rather than calling
  /// upload_session/finish, use this route to finish all your upload sessions
  /// in a single request. UploadSessionStartArg.close or UploadSessionAppendArg.close
  /// needs to be true for the last upload_session/start or upload_session/append:2
  /// call of each upload session. The maximum size of a file one can upload to an
  /// upload session is 350 GB. We allow up to 1000 entries in a single request.
  /// Calls to this endpoint will count as data transport calls for any Dropbox Business
  /// teams with a limit on the number of data transport calls allowed per month.
  /// For more information, see the Data transport limit page.
  ///
  /// `entries`: List of entries containing the session ID, offset, and path. 'error'.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Returns the status of an asynchronous job for upload_session/finish_batch.
  /// If success, it returns a list of results for each entry.
  ///
  /// `asyncJobId`: The asynchronous job ID.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// Upload sessions allow you to upload a single file in one or more requests, for example
  /// where the size of the file is greater than 150 MB. This call starts a new upload session
  /// with the given data. You can then use upload_session/append:2 to add more data and
  /// upload_session/finish to save all the data to a file in Dropbox. A single request should
  /// not upload more than 150 MB. The maximum size of a file one can upload to an upload
  /// session is 350 GB. An upload session can be used for a maximum of 7 days. Attempting
  /// to use an UploadSessionStartResult.session_id with upload_session/append:2 or
  /// upload_session/finish more than 7 days after its creation will return a
  /// UploadSessionLookupError.not_found. Calls to this endpoint will count as data transport
  /// calls for any Dropbox Business teams with a limit on the number of data transport
  /// calls allowed per month. For more information, see the Data transport limit page.
  ///
  /// By default, upload sessions require you to send content of the file in sequential order
  /// via consecutive upload_session/start, upload_session/append:2, upload_session/finish calls.
  /// For better performance, you can instead optionally use a UploadSessionType.concurrent upload session.
  /// To start a new concurrent session, set UploadSessionStartArg.session_type to
  /// UploadSessionType.concurrent. After that, you can send file data in concurrent
  /// upload_session/append:2 requests. Finally finish the session with upload_session/finish.
  /// There are couple of constraints with concurrent sessions to make them work.
  /// You can not send data with upload_session/start or upload_session/finish call,
  /// only with upload_session/append:2 call. Also data uploaded in upload_session/append:2
  /// call must be a multiple of 4194304 bytes (except for the last upload_session/append:2
  /// with UploadSessionStartArg.close set to true, that may contain any remaining data).
  ///
  /// `localFilePath`: The local file path to upload.
  Future<Map<String, dynamic>> uploadSessionStart(String localFilePath, {bool close = false}) async {
    final Uri uri = Uri.parse('https://content.dropboxapi.com/2/files/upload_session/start');
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${_dropbox.accessToken}',
      'Content-Type': 'application/octet-stream',
      'Dropbox-API-Arg': '{"close": $close}',
    };

    final File file = File(localFilePath);
    final List<int> fileContent = await file.readAsBytes();

    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: fileContent,
    );

    if (response.statusCode == 200) {
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }

  /// This route starts a batch of upload sessions. Please refer to `upload_session/start` usage.
  /// Calls to this endpoint will count as data transport calls for any Dropbox Business teams
  /// with a limit on the number of data transport calls allowed per month.
  /// For more information, see the Data transport limit page.
  ///
  /// `numSessions`: The number of upload sessions to start.
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
      return {'success': true, 'result': jsonDecode(response.body)};
    } else {
      return {'success': false, 'error': response.body};
    }
  }
}
