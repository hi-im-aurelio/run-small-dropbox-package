import 'package:run_small_dropbox/run_small_dropbox.dart';
import 'package:universal_io/io.dart';

void main(List<String> args) {
  // Pegue o link temporario de um arquivo.
  getTemporaryFileLink(commonParameter('token'), bodyParameterToAcquireTheTemporaryLink('/path/file'));

  // Crie uma nova pasta em seu dropbox.
  createFolder(commonParameter('token'), bodyParameterForFolderCreation('/my-new-folder'));

  // Mova um arquivo.
  moveFile(commonParameter('token'), bodyParameterToMoveFile('from-this-path', 'to-here-path'));

  // Copie um arquivo.
  copyFile(commonParameter('token'), bodyParameterToCopyFile('from-this-path', 'to-here-path'));

  // Apageue um arquivo.
  deleteFile(commonParameter('token'), bodyParameterToDeleteFile('/path/file'));

  // Obtenha um novo token de acesso.
  refreshToken(refreshToken: Authentication.refreshToken, appKey: Authentication.appKey, secretKey: Authentication.appSecret);

  // Carregue um arquivo para o seu dropbox.
  uploadFile(UploadFiles('token', 'up-to'), File(''));
}

Map apiconsole = {
  "refresh_token": "your refresh token",
  'appKey': 'your app key',
  'appSecret': 'your secrect key',
};

class Authentication {
  static String appKey = apiconsole['appKey'];
  static String appSecret = apiconsole['appSecret'];
  static String refreshToken = apiconsole['refresh_token'];
}
