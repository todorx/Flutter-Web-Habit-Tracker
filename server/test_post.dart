import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.post(
    Uri.parse('http://localhost:8080/api/habits'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': 'Test',
      'description': 'test',
      'color': 12345,
      'icon': 'abc',
      'frequency': 'daily',
    }),
  );
  print(res.statusCode);
  print(res.body);
}
