import 'dart:convert';
import 'package:http/http.dart' as http;

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class JsonController {
  static final JsonController _instance = JsonController._internal();
  factory JsonController() => _instance;
  JsonController._internal();

  Future<List<T>> loadFromNetwork<T>({
    required String url,
    required FromJson<T> fromJson,
  }) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load data from $url');
    }
  }
}
