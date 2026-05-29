import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';

class DioClient {
  DioClient._();
  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio dio = _createDio();

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onError: (error, handler) {
          print(
            '[DioClient] Error: ${error.response?.statusCode} '
            '${error.requestOptions.path}',
          );
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
