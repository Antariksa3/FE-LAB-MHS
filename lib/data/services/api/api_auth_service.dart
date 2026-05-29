import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../abstract/i_auth_service.dart';
import 'dio_client.dart';

class ApiAuthService implements IAuthService {
  final Dio _dio = DioClient.instance.dio;

  @override
  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final body = response.data as Map<String, dynamic>;

      if (body['status'] != 'success') {
        throw Exception(body['message'] ?? 'Login gagal');
      }

      return {'token': body['token'], 'user': body['user']};
    } on DioException catch (e) {
      throw Exception(_parseDioError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      throw UnimplementedError(
        'loginWithGoogle via API belum di-implement. '
        'Perlu google_token dari GoogleSignIn SDK.',
      );
    } on DioException catch (e) {
      throw Exception(_parseDioError(e));
    }
  }

  String _parseDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        return data['message'];
      }
      switch (e.response!.statusCode) {
        case 400:
          return 'Request tidak valid';
        case 401:
          return 'Email atau password salah';
        case 403:
          return 'Akses ditolak';
        case 404:
          return 'Endpoint tidak ditemukan';
        case 500:
          return 'Server error. Coba lagi nanti.';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
