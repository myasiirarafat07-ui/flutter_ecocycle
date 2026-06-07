import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_api_service.dart';
import '../../widgets/app_text_field.dart';
import '../main_wrapper.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApi = AuthApiService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authApi.login(email: email, password: password);

      if (!mounted) return;

      context.read<UserProvider>().setAuthenticatedUser(
        token: result.token,
        user: result.user,
      );
      context.read<CartProvider>().load(result.token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapper()),
      );
    } on AuthApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa terhubung ke server'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  void _goToRegister() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const RegisterScreen()),
  );

  void _handleForgotPassword() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Fitur lupa password segera hadir')),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildHeroImage(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    _buildHeading(),
                    const SizedBox(height: 28),
                    LabeledField(
                      label: 'Email',
                      child: AppTextField(
                        controller: _emailController,
                        hint: 'Masukkan email Anda',
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: Icons.mail_outline,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    _buildLoginButton(),
                    const SizedBox(height: 28),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Tidak memiliki akun? ",
                            style: TextStyle(
                              color: context.mutedColor,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: _goToRegister,
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        '© 2026 EcoCycle. All rights reserved.',
                        style: TextStyle(color: context.mutedColor, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: Image.asset('assets/logo/ecocycle_logo.png'),
        ),
        Expanded(
          child: Text(
            'EcoCycle',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    ),
  );

  Widget _buildHeroImage() => Container(
    height: 200,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: context.surfaceColor,
    ),
    clipBehavior: Clip.hardEdge,
    child: Image.asset(
      'assets/images/login_picture.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ),
  );

  Widget _buildHeading() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Selamat Datang Kembali!',
        style: TextStyle(
          color: context.textColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        "Mari lanjutkan perjalananmu menuju dunia yang lebih hijau",
        style: TextStyle(color: context.mutedColor, fontSize: 14, height: 1.4),
      ),
    ],
  );

  Widget _buildPasswordField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Kata Sandi',
            style: TextStyle(color: context.textColor, fontSize: 14),
          ),
          GestureDetector(
            onTap: _handleForgotPassword,
            child: const Text(
              'Lupa Kata Sandi?',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      AppTextField(
        controller: _passwordController,
        hint: 'Masukkan kata sandi Anda',
        obscureText: _obscurePassword,
        suffixIcon: _obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    ],
  );

  Widget _buildLoginButton() => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Masuk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    ),
  );
}
