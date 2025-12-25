import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<dynamic>> getList(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded;
      }
      if (decoded is Map && decoded['data'] is List) {
        return decoded['data'] as List;
      }
      throw Exception('Unexpected response format');
    }
    throw Exception('Request failed: ${response.statusCode}');
  }
}
