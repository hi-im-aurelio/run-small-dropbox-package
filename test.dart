import 'package:http/http.dart' as http;

void main() async {
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  var data = {
    'code': '',
  };

  var url = Uri.parse('https://api.dropboxapi.com/oauth2/token');
  var res = await http.post(url, headers: headers, body: data);
  if (res.statusCode != 200) throw Exception('http.post error: statusCode= ${res.statusCode}');
  print(res.body);
}
