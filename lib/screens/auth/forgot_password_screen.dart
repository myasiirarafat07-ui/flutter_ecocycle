import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_api_service.dart';
import '../../widgets/app_text_field.dart';

enum _ResetStep { requestInfo, enterOtp, newPassword }

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authApi = AuthApiService();

  late final TextEditingController _emailController;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _ResetStep _step = _ResetStep.requestInfo;
  String _resetToken = '';
  String? _devOtp;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
    } on AuthApiException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError('Tidak bisa terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || phone.isEmpty) {
      _showError('Email dan nomor HP tidak boleh kosong');
      return;
    }
    if (!_isValidEmail(email)) {
      _showError('Format email tidak valid');
      return;
    }

    await _runGuarded(() async {
      final devOtp = await _authApi.forgotPassword(
        email: email,
        phoneNumber: phone,
      );
      if (!mounted) return;
      setState(() {
        _devOtp = devOtp;
        // Mode dev: SMTP belum dikonfigurasi, isi otomatis agar mudah diuji.
        if (devOtp != null) _otpController.text = devOtp;
        _step = _ResetStep.enterOtp;
      });
      _showSuccess(
        devOtp == null
            ? 'Kode OTP telah dikirim ke email Anda'
            : 'Kode OTP (mode dev): $devOtp',
      );
    });
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _showError('Masukkan 6 digit kode OTP');
      return;
    }

    await _runGuarded(() async {
      final token = await _authApi.verifyOtp(
        email: _emailController.text.trim().toLowerCase(),
        otp: otp,
      );
      if (!mounted) return;
      setState(() {
        _resetToken = token;
        _step = _ResetStep.newPassword;
      });
    });
  }

  Future<void> _handleResetPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 6) {
      _showError('Kata sandi minimal 6 karakter');
      return;
    }
    if (password != confirm) {
      _showError('Konfirmasi kata sandi tidak cocok');
      return;
    }

    await _runGuarded(() async {
      await _authApi.resetPassword(
        resetToken: _resetToken,
        newPassword: password,
      );
      if (!mounted) return;
      _showSuccess('Kata sandi berhasil diperbarui. Silakan masuk.');
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        foregroundColor: context.textColor,
        title: Text(
          'Lupa Kata Sandi',
          style: TextStyle(
            color: context.textColor,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeading(),
              const SizedBox(height: 28),
              ..._buildStepFields(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading() {
    final (title, subtitle) = switch (_step) {
      _ResetStep.requestInfo => (
        'Verifikasi Akun',
        'Masukkan email dan nomor HP yang terdaftar untuk menerima kode OTP.',
      ),
      _ResetStep.enterOtp => (
        'Masukkan Kode OTP',
        _devOtp != null
            ? 'Mode dev (email belum dikonfigurasi): kode OTP sudah terisi otomatis.'
            : 'Kami telah mengirim 6 digit kode ke ${_emailController.text.trim()}.',
      ),
      _ResetStep.newPassword => (
        'Kata Sandi Baru',
        'Buat kata sandi baru untuk akun EcoCycle kamu.',
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: context.mutedColor, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  List<Widget> _buildStepFields() {
    switch (_step) {
      case _ResetStep.requestInfo:
        return [
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
          LabeledField(
            label: 'Nomor HP',
            child: AppTextField(
              controller: _phoneController,
              hint: 'Masukkan nomor HP terdaftar',
              keyboardType: TextInputType.phone,
              suffixIcon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton('Kirim Kode', _handleSendCode),
        ];

      case _ResetStep.enterOtp:
        return [
          LabeledField(
            label: 'Kode OTP',
            child: AppTextField(
              controller: _otpController,
              hint: '6 digit kode',
              keyboardType: TextInputType.number,
              suffixIcon: Icons.password_outlined,
            ),
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton('Verifikasi', _handleVerifyOtp),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _isLoading ? null : _handleSendCode,
              child: const Text(
                'Kirim ulang kode',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ];

      case _ResetStep.newPassword:
        return [
          LabeledField(
            label: 'Kata Sandi Baru',
            child: AppTextField(
              controller: _passwordController,
              hint: 'Masukkan kata sandi baru',
              obscureText: _obscurePassword,
              suffixIcon: _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              onSuffixTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Konfirmasi Kata Sandi',
            child: AppTextField(
              controller: _confirmController,
              hint: 'Ulangi kata sandi baru',
              obscureText: _obscureConfirm,
              suffixIcon: _obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              onSuffixTap: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton('Simpan', _handleResetPassword),
        ];
    }
  }

  Widget _buildPrimaryButton(String label, Future<void> Function() onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
