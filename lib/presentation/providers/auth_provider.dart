import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/services/abstract/i_auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final IAuthService _authService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _token;
  String? _errorMessage;

  AuthProvider(this._authService);

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  Future<void> tryAutoLogin() async {
    _setStatus(AuthStatus.loading);

    try {
      final savedToken = await _storage.read(key: 'auth_token');
      final savedRole = await _storage.read(key: 'user_role');
      final savedName = await _storage.read(key: 'user_name');
      final savedEmail = await _storage.read(key: 'user_email');
      final savedId = await _storage.read(key: 'user_id');

      if (savedToken != null &&
          savedToken.length >= 20 &&
          savedRole != null &&
          savedId != null) {
        _token = savedToken;
        _currentUser = UserModel(
          id: int.parse(savedId),
          name: savedName ?? 'User',
          email: savedEmail ?? '',
          role: savedRole,
        );
        _setStatus(AuthStatus.authenticated);
      } else {
        await _clearStorage();
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (_) {
      await _clearStorage();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      final result = await _authService.loginWithEmail(email, password);
      await _handleAuthSuccess(result);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    try {
      final result = await _authService.loginWithGoogle();
      await _handleAuthSuccess(result);
      return true;
    } catch (e) {
      _errorMessage = 'Google Sign-In gagal. Coba lagi.';
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<void> logout() async {
    await _clearStorage();
    _token = null;
    _currentUser = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> result) async {
    final token = result['token'] as String;
    final userData = result['user'] as Map<String, dynamic>;
    if (token.length < 20) {
      throw Exception('Token tidak valid dari server');
    }

    _token = token;
    _currentUser = UserModel.fromJson(userData);

    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'user_role', value: _currentUser!.role);
    await _storage.write(key: 'user_name', value: _currentUser!.name);
    await _storage.write(key: 'user_email', value: _currentUser!.email);
    await _storage.write(key: 'user_id', value: _currentUser!.id.toString());

    _setStatus(AuthStatus.authenticated);
  }

  Future<void> _clearStorage() async {
    await _storage.deleteAll();
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}
