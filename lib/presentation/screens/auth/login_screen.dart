import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gold_button.dart';
import '../../widgets/common/google_sign_in_button.dart';
import '../admin/admin_dashboard_screen.dart';
import '../user/user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithEmail(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      _navigateByRole(auth);
    } else {
      _showErrorSnackbar(auth.errorMessage ?? 'Login gagal');
    }
  }

  Future<void> _handleGoogleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithGoogle();

    if (!mounted) return;

    if (success) {
      _navigateByRole(auth);
    } else {
      _showErrorSnackbar(auth.errorMessage ?? 'Google Sign-In gagal');
    }
  }

  void _navigateByRole(AuthProvider auth) {
    final destination = auth.isAdmin
        ? const AdminDashboardScreen()
        : const UserHomeScreen();

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              _buildHeader(context),

              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 8),
                    _buildRememberMeRow(),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _buildLoginButton(context),

              const SizedBox(height: 20),
              _buildDivider(),

              const SizedBox(height: 20),
              GoogleSignInButton(onPressed: _handleGoogleLogin),

              const SizedBox(height: 40),
              _buildTestAccountHint(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.accent, width: 2),
          ),
          child: const Icon(
            Icons.shield_rounded,
            size: 40,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'GENSHIN IMPORT',
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to your Teyvat account',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
      ),
      validator: Validators.email,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.textSecondary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: Validators.password,
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
            activeColor: AppColors.accent,
            side: const BorderSide(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text('Remember me', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final isLoading = auth.status == AuthStatus.loading;
        return GoldButton(
          label: isLoading ? 'Signing in...' : 'Sign In',
          isLoading: isLoading,
          onPressed: isLoading ? null : _handleEmailLogin,
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.primaryMedium)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.primaryMedium)),
      ],
    );
  }

  Widget _buildTestAccountHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔑 Test Accounts (Dev Mode)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'User  : user@test.com / user123',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Admin : admin@test.com / admin123',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
