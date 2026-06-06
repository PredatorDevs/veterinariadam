import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 15);

  final String baseUrl;
  final http.Client _client;
  final Duration _timeout;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final sanitizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$sanitizedPath').replace(
      queryParameters: query?.map((key, value) => MapEntry(key, '$value')),
    );
  }

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  dynamic _handleResponse(http.Response response) {
    final payload = _decodeBody(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }

    String message = 'Error inesperado en la API';

    if (payload is Map && payload['mensaje'] is String) {
      message = payload['mensaje'] as String;
    } else if (payload is String && payload.trim().isNotEmpty) {
      message = payload;
    }

    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final response = await _client
        .get(_uri(path, query), headers: _jsonHeaders)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _client
        .post(
          _uri(path),
          headers: _jsonHeaders,
          body: jsonEncode(body ?? <String, dynamic>{}),
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await _client
        .put(
          _uri(path),
          headers: _jsonHeaders,
          body: jsonEncode(body ?? <String, dynamic>{}),
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _client
        .delete(_uri(path), headers: _jsonHeaders)
        .timeout(_timeout);
    return _handleResponse(response);
  }
}
