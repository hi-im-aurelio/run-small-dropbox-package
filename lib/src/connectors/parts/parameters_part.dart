class PaperUpdate {
  final String token;
  final String uptadeThis;

  PaperUpdate(this.token, this.uptadeThis);

  Map<String, String> headers() {
    return {
      'Authorization': 'Bearer $token',
      'Dropbox-API-Arg': '{"doc_update_policy":"update","import_format":"html","paper_revision":123,"path":"$uptadeThis"}',
      'Content-Type': 'application/octet-stream',
    };
  }
}

class PaperCreate {
  final String token;
  final String inThisPath;

  PaperCreate(this.token, this.inThisPath);
  Map<String, String> headers() {
    return {
      'Authorization': 'Bearer $token',
      'Dropbox-API-Arg': '{"import_format":"html","path":"$inThisPath"}',
      'Content-Type': 'application/octet-stream',
    };
  }
}

class UploadFiles {
  final String token;
  final String goUpTo;

  UploadFiles(this.token, this.goUpTo);

  Map<String, String> headers() {
    return {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/octet-stream',
      'Dropbox-API-Arg': '{"path":  "$goUpTo", "mode": "overwrite"}',
    };
  }
}

Map<String, String> commonParameter(String token) {
  return {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
}

Map<String, String> bodyParameterToAcquireTheTemporaryLink(String path) {
  return {"path": path};
}

Map<String, dynamic> bodyParameterToCopyFile(String onTheWay, String toTheWay) {
  return {"allow_ownership_transfer": false, "allow_shared_folder": false, "autorename": false, "from_path": onTheWay, "to_path": toTheWay};
}

Map<String, dynamic> bodyParameterToMoveFile(String onTheWay, String toTheWay) {
  return {"allow_ownership_transfer": false, "allow_shared_folder": false, "autorename": false, "from_path": onTheWay, "to_path": toTheWay};
}

Map<String, dynamic> bodyParameterForFolderCreation(String path) {
  return {"autorename": false, "path": path};
}

Map<String, dynamic> bodyParameterToDeleteFile(String path) {
  return {"path": path};
}
