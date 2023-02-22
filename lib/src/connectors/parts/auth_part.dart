class Auth {
  static final String auth = 'https://api.dropbox.com/oauth2/token?';
  static String isRefresh = '';

  final String refreshToken;
  final String appKey;
  final String secretKey;

  Auth({
    required this.refreshToken,
    required this.appKey,
    required this.secretKey,
  }) {
    isRefresh =
        '${auth}refreshtoken=$refreshToken&granttype=refreshtoken&clientid=$appKey&clientsecret=$secretKey';
  }

  String get refresh => isRefresh;
}
