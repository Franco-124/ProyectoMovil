import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _dio = ApiClient.instance;

  Future<UserModel> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'username': email,
      'password': password,
    }, options: Options(
      contentType: 'application/x-www-form-urlencoded',
    ));

    final token = res.data['access_token'] as String;
    await SecureStorage.saveToken(token);

    // Obtener datos del usuario
    return await getMe();
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'full_name': fullName,
    });

    final token = res.data['access_token'] as String;
    await SecureStorage.saveToken(token);

    return await getMe();
  }

  Future<UserModel> getMe() async {
    final res = await _dio.get('/auth/me');
    return UserModel.fromJson(res.data);
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
  }
}
