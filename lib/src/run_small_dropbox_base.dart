import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart';

import 'connectors/parts/urs_part.dart';
import 'connectors/parts/auth_part.dart';
import 'connectors/parts/parameters_part.dart';

Future<Response> getTemporaryFileLink(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.getTemporaryFileLink), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

Future<Response> createFolder(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.createFolder), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

Future<Response> moveFile(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.moveFile), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

Future<Response> copyFile(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.copyFile), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

Future<Response> deleteFile(Map<String, String>? headers, Object? body) async {
  Future<Response> response = post((EndPoints.deleteFile), headers: headers, body: jsonEncode(body));
  return await response.then((responseReceived) => responseReceived);
}

/// Use para obter um novo token quando o em uso for a expirar.
///
Future<Response> refreshToken({required refreshToken, required appKey, required secretKey}) async {
  Future<Response> response = post(Uri.parse(Auth(refreshToken: refreshToken, appKey: appKey, secretKey: secretKey).refresh));
  return await response.then((responseReceived) => responseReceived);
}

Future<Response> uploadFile(UploadFiles connector, File file) async {
  Uint8List data = await file.readAsBytes();

  final response = await post(EndPoints.uploadFile, body: data, headers: connector.headers());

  return response;
}
