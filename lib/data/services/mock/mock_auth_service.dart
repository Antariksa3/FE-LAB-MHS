import '../abstract/i_auth_service.dart';

class MockAuthService implements IAuthService {
  final _mockUsers = [
    {
      'id': 1,
      'name': 'Traveler',
      'email': 'user@test.com',
      'password': 'user123',
      'role': 'user',
    },
    {
      'id': 2,
      'name': 'Paimon',
      'email': 'admin@test.com',
      'password': 'admin123',
      'role': 'admin',
    },
  ];

  @override
  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = _mockUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) {
      throw Exception('Email atau password salah');
    }

    final mockToken = 'mock${user['role']}token${user['id']}xgenshin2024z';

    return {
      'token': mockToken,
      'user': {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'role': user['role'],
      },
    };
  }

  @override
  Future<Map<String, dynamic>> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {
      'token': 'mockgoogletoken9z8y7xw6v5u4t3s2r1q0alphanum',
      'user': {
        'id': 99,
        'name': 'Google User',
        'email': 'googleuser@gmail.com',
        'role': 'user',
      },
    };
  }
}
