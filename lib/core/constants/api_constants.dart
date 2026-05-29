class ApiConstants {
  ApiConstants._();
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';

  static const String weapons = '/weapons';
  static String weaponById(int id) => '/weapons/$id';

  static const String orders = '/orders';
}
