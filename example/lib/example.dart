import 'package:run_small_dropbox/run_small_dropbox.dart';

// import 'package:universal_io/io.dart';

void main() async {
  const accessToken = 'YOU_ACCESS_TOKEN';
  final dropboxApp = Dropbox.initializeApp(accessToken);

  final dropboxFile = DropboxFile(dropboxApp);

  var data = await dropboxFile.getTemporaryLink('/Moviern/movies.json');
  print(data);
}
