import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/weapon_model.dart';
import '../abstract/i_weapon_service.dart';
import 'dio_client.dart';

class ApiWeaponService implements IWeaponService {
  final Dio _dio = DioClient.instance.dio;

  @override
  Future<List<WeaponModel>> getAll() async {
    try {
      final response = await _dio.get(ApiConstants.weapons);
      final body = response.data as Map<String, dynamic>;

      if (body['status'] != 'success') {
        throw Exception(body['message'] ?? 'Gagal memuat data');
      }

      final List<dynamic> raw = body['data'];
      return raw.map((e) => WeaponModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_parseDioError(e));
    }
  }

  @override
  Future<WeaponModel> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.weaponById(id));
      final body = response.data as Map<String, dynamic>;

      if (body['status'] != 'success') {
        throw Exception(body['message'] ?? 'Item tidak ditemukan');
      }

      return WeaponModel.fromJson(body['data']);
    } on DioException catch (e) {
      throw Exception(_parseDioError(e));
    }
  }

  @override
  Future<void> create(WeaponModel weapon) async {
    try {
      final response = await _dio.post(
        ApiConstants.weapons,
        data: weapon.toJson(),
      );
      final body = response.data as Map<String, dynamic>;

      if (body['status'] != 'success') {
        throw Exception(body['message'] ?? 'Gagal menambahkan item');
      }
    } on DioException catch (e) {
      throw Exception(_parseDioError(e));
    }
  }

  @override
  Future<void> update(int id, WeaponModel weapon) async {
    try {
      final response = await _dio.put(
        ApiConstants.weaponById(id),
        data: weapon.toJson(),
      );
      final body = response.data as Map<String, dynamic>;

      if (body['status'] != 'success') {
        throw Exception(body['message'] ?? 'Gagal mengubah item');
      }
    } on DioException catch (e) {
      throw Exception(_parseDioError(e));
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final response = await _dio.delete(ApiConstants.weaponById(id));
      final body = response.data as Map<String, dynamic>;

      if (body['status'] != 'success') {
        throw Exception(body['message'] ?? 'Gagal menghapus item');
      }
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
        case 401:
          return 'Sesi habis. Silakan login kembali.';
        case 403:
          return 'Akses ditolak. Admin only.';
        case 404:
          return 'Item tidak ditemukan.';
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
