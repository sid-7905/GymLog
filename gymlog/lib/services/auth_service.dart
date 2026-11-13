import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    final token = response['token'] as String;
    await _apiService.saveToken(token);

    final user = UserModel.fromJson(response['user']);
    return {'token': token, 'user': user};
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    final token = response['token'] as String;
    await _apiService.saveToken(token);

    final user = UserModel.fromJson(response['user']);
    return {'token': token, 'user': user};
  }

  Future<UserModel> getMe() async {
    final response = await _apiService.get('/auth/me', requiresAuth: true);
    return UserModel.fromJson(response['user']);
  }

  Future<void> logout() async {
    await _apiService.clearToken();
  }

  Future<String?> getToken() async {
    return await _apiService.getToken();
  }
}
