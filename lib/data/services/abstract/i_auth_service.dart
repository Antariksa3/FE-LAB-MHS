abstract class IAuthService {
  Future<Map<String, dynamic>> loginWithEmail(String email, String password);
  Future<Map<String, dynamic>> loginWithGoogle();
}
