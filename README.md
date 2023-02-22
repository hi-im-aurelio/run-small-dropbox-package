
A simple package to access dropbox, using dart.

## Features
<ul>
   <li>[#NEW] Create a paper document</li>
   <li>[#NEW] Update a Paper document</li>
   <li>Move files from dropbox</li>
   <li>Copy files from dropbox</li>
   <li>Delete files from dropbox</li>
   <li>Get a file link from dropbox</li>
   <li>Refresh token</li>
   <li>Create folder in dropbox</li>
   <li>Upload file to dropbox</li>
</ul>

## NEWS
Creating a paper document in dropobox.
~~~bash
paperCreate(PaperCreate(<token>, 'path'));
~~~

## Getting started

~~~bash
dart pub add run_small_dropbox
~~~

## Usage

NOTE: I initially created this package to help me with my applications, because I couldn't find a package that helped me work with dropbox using dart.

The package currently only provides 6 functionality; that of getting a temporary link to a file, creating a folder, moving, copying and deleting a file, uploading a file, getting or refring your token.

Well, follow the examples on how to use the package:

Well, the basics first. Import it:

~~~dart
import 'package:run_small_dropbox/run_small_dropbox.dart';
~~~

Get the temporary link of a file.
~~~dart
void main() {
   getTemporaryFileLink(commonParameter('token'), bodyParameterToAcquireTheTemporaryLink('/path/file'));
}
~~~

Create a new folder in your dropbox.
~~~dart
void main() {
   createFolder(commonParameter('token'), bodyParameterForFolderCreation('/my-new-folder'));
}
~~~

Copy a file.
~~~dart
void main() {
   copyFile(commonParameter('token'), bodyParameterToCopyFile('from-this-path', 'to-here-path'));
}
~~~

Delete a file.
~~~dart
void main() {
   deleteFile(commonParameter('token'), bodyParameterToDeleteFile('/path/file'));
}
~~~

Upload a file to dropbox.
Load any binary file.
~~~dart
void main() {
   uploadFile(UploadFiles('token', 'up-to'), File(''));
}
~~~

Move the file.
~~~dart
void main() {
   moveFile(commonParameter('token'), bodyParameterToMoveFile('from-this-path', 'to-here-path'));
}
~~~


Get a new access token.
~~~dart
map apiconsole = {
   "refresh_token": "your refresh token",
   'appKey': 'your app key',
   'appSecret': 'your secret key',
};

class Authentication {
   static String appKey = apiconsole['appKey'];
   static String appSecret = apiconsole['appSecret'];
   static String refreshToken = apiconsole['refresh_token'];
}

void main() {
   refreshToken(refreshToken: Authentication.refreshToken, appKey: Authentication.appKey, secretKey: Authentication.appSecret);
}
~~~


## Additional information

Each of these functions returns a Response object. Use it as you please.

Good coding.
