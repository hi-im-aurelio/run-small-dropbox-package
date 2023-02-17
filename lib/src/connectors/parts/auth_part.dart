class Auth {
  static final String _auth = 'https://api.dropbox.com/oauth2/token?';
  static String _refresh = '';

  final String _refreshToken, _appKey, _secretKey;

  Auth({required refreshToken, required appKey, required secretKey})
      : _refreshToken = refreshToken,
        _appKey = appKey,
        _secretKey = secretKey {
    _refresh = '${_auth}refresh_token=$_refreshToken&grant_type=refresh_token&client_id=$_appKey&client_secret=$_secretKey';
  }

  String get refresh => _refresh;
}