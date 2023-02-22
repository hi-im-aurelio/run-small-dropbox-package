import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:universal_io/io.dart';
import 'connectors/parts/urs_part.dart';
import 'connectors/parts/auth_part.dart';
import 'connectors/parts/parameters_part.dart';

/// Updates an existing Paper doc with the provided content.
///
// Does not support apps with app folder permission.
Future<Response> paperUpdate(PaperUpdate headers, File file) async {
  Uint8List data = await file.readAsBytes();

  Future<Response> response = post(EndPoints.paperUpdate, headers: headers.headers(), body: data);
  return await response.then((responseReceived) => responseReceived);
}

/// Creates a new Paper doc with the given content.
///
// Does not support apps with app folder permission.
Future<Response> paperCreate(PaperCreate headers, File file) async {
  Uint8List data = await file.readAsBytes();

  Future<Response> response = post(EndPoints.paperCreate, headers: headers.headers(), body: data);
  return await response.then((responseReceived) => responseReceived);
}

/// Get a temporary link of a file.\
///
Future<Response> getTemporaryFileLink(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.getTemporaryFileLink), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

/// Create a folder in your dropbox.
///
Future<Response> createFolder(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.createFolder), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

/// Move files in the dropbox environment.
///
Future<Response> moveFile(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.moveFile), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

/// Copy files in the dropbox environment.
///
Future<Response> copyFile(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.copyFile), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

/// Delete files in the dropbox environment.
///
Future<Response> deleteFile(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.deleteFile), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

/// Use to get a new token when the one in use is about to expire.
///
Future<Response> refreshToken({required refreshToken, required appKey, required secretKey}) async {
  Future<Response> response = post(Uri.parse(Auth(refreshToken: refreshToken, appKey: appKey, secretKey: secretKey).refresh));
  return await response.then((responseReceived) => responseReceived);
}

/// Update files in the dropbox environment.
///
Future<Response> uploadFile(UploadFiles connector, File file) async {
  Uint8List data = await file.readAsBytes();

  final response = await post(EndPoints.uploadFile, body: data, headers: connector.headers());

  return response;
}
