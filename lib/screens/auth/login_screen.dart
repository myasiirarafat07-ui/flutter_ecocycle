import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../main_wrapper.dart';
import 'register_screen.dart';

// ============================================================
// LOGIN SCREEN
// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Email dan password tidak boleh kosong'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() => _isLoading = true);

    // try {
    //   await AuthService.login(email: email, password: password);
    //   if (!mounted) return;
    //   Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (_) => const MainWrapper()));
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Login gagal: $e'), backgroundColor: Colors.red));
    // } finally {
    //   setState(() => _isLoading = false);
    // }

    // Simulasi delay — HAPUS setelah API terhubung
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainWrapper()),
    );
  }

  void _goToRegister() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur lupa password segera hadir')));
  }

  void _loginWithGoogle() {
  }

  void _loginWithApple() {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
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
                    _buildEmailField(),
                    const SizedBox(height: 18),
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildSocialButtons(),
                    const SizedBox(height: 28),
                    _buildSignUpLink(),
                    const SizedBox(height: 20),
                    _buildCopyright(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Image.asset('assets/logo/ecocycle_logo.png'),
            // child: Image.asset('assets/images/logo.png')
          ),
          const Expanded(
            child: Text('EcoCycle',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.bgCard,
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.asset(
        'assets/images/login_picture.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildHeading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back',
            style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text("Let's continue your journey to a greener world",
            style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.4)),
      ],
    );
  }

  Widget _buildEmailField() {
    return LabeledField(
      label: 'Email',
      child: AppTextField(
        controller: _emailController,
        hint: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        suffixIcon: Icons.mail_outline,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Password',
                style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
            GestureDetector(
              onTap: _handleForgotPassword,
              child: const Text('Forgot Password?',
                  style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _passwordController,
          hint: 'Enter your password',
          obscureText: _obscurePassword,
          suffixIcon: _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text('Login',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text('Or continue with',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ),
        Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: Image.asset('assets/logo/google_logo.png', width: 22, height: 22),
            label: 'Google',
            onTap: _loginWithGoogle,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _SocialButton(
            icon: Image.asset('assets/logo/apple_logo.png', width: 25, height: 25),
            label: 'Apple',
            onTap: _loginWithApple,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account? ",
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          GestureDetector(
            onTap: _goToRegister,
            child: const Text('Sign Up',
                style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return const Center(
      child: Text('© 2024 EcoCycle. All rights reserved.',
          style: TextStyle(color: Colors.white24, fontSize: 12)),
    );
  }
}

// ============================================================
// SOCIAL BUTTON (hanya dipakai di login screen)
// ============================================================
class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}