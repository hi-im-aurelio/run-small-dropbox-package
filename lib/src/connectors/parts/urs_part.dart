class EndPoints {
  static final String _andress = 'https://api.dropboxapi.com/2';
  static final String _andress2 = 'https://content.dropboxapi.com/2';

  static Uri paperUpdate = Uri.parse('$_andress/files/paper/update');
  static Uri paperCreate = Uri.parse('$_andress/files/paper/create');
  static Uri copyFile = Uri.parse('$_andress/files/copy_v2');
  static Uri createFolder = Uri.parse('$_andress/files/create_folder_v2');
  static Uri uploadFile = Uri.parse('$_andress2/files/upload');
  static Uri deleteFile = Uri.parse('$_andress/files/delete_v2');
  static Uri moveFile = Uri.parse('$_andress/files/move_v2');
  static Uri getTemporaryFileLink = Uri.parse('$_andress/files/get_temporary_link');
}
