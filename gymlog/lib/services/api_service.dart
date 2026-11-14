import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'gymlog_jwt_token';
  static String? _customUrl;

  static void setCustomUrl(String url) {
    _customUrl = url.trim();
  }

  static String get currentBaseUrl {
    if (_customUrl != null && _customUrl!.isNotEmpty) {
      return _customUrl!.endsWith('/')
          ? _customUrl!.substring(0, _customUrl!.length - 1)
          : _customUrl!;
    }

    String? url;
    try {
      if (dotenv.isInitialized) {
        url = dotenv.env['API_BASE_URL'];
      }
    } catch (e) {
      debugPrint('Warning reading dotenv: $e');
    }

    if (url == null || url.isEmpty) {
      url = 'https://gymlogbackend.onrender.com/api';
    }

    // Automatically adapt 10.0.2.2 for desktop / web environments
    if (kIsWeb) {
      if (url.contains('10.0.2.2')) {
        url = url.replaceAll('10.0.2.2', 'localhost');
      }
    } else {
      if ((Platform.isWindows || Platform.isMacOS || Platform.isLinux) &&
          url.contains('10.0.2.2')) {
        url = url.replaceAll('10.0.2.2', '127.0.0.1');
      }
    }

    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  String get baseUrl => currentBaseUrl;

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('Error reading auth token: $e');
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('Error saving auth token: $e');
    }
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('Error clearing auth token: $e');
    }
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    debugPrint('[API] Response (${response.statusCode}): ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      String errorMessage = 'Request failed';
      if (body is Map && body.containsKey('message')) {
        errorMessage = body['message'].toString();
      } else if (response.reasonPhrase != null) {
        errorMessage = response.reasonPhrase!;
      }
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    debugPrint('[API] GET $uri');

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      debugPrint('[API GET Error] $e');
      if (e is ApiException) rethrow;
      throw ApiException(
          'Network connection error to $baseUrl: Please ensure backend server is running ($e)');
    }
  }

  Future<dynamic> post(String endpoint,
      {dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    debugPrint('[API] POST $uri');

    try {
      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      debugPrint('[API POST Error] $e');
      if (e is ApiException) rethrow;
      throw ApiException(
          'Network connection error to $baseUrl: Please ensure backend server is running ($e)');
    }
  }

  Future<dynamic> put(String endpoint,
      {dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    debugPrint('[API] PUT $uri');

    try {
      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      debugPrint('[API PUT Error] $e');
      if (e is ApiException) rethrow;
      throw ApiException(
          'Network connection error to $baseUrl: Please ensure backend server is running ($e)');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    debugPrint('[API] DELETE $uri');

    try {
      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      debugPrint('[API DELETE Error] $e');
      if (e is ApiException) rethrow;
      throw ApiException(
          'Network connection error to $baseUrl: Please ensure backend server is running ($e)');
    }
  }
}
