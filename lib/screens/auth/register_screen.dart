import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_text_field.dart';
import '../main_wrapper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  String _selectedUserType = 'Individual';
  final List<String> _userTypes = [
    'Individual',
    'Petani',
    'Bisnis',
    'Organisasi',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap setujui Syarat Layanan terlebih dahulu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua kolom yang wajib diisi'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Simpan data user ke provider
    context.read<UserProvider>().registerAs(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      userType: _selectedUserType,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainWrapper()),
      (_) => false,
    );
  }

  void _goToLogin() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          _buildHeroTop(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverlayBrand(),
                  const SizedBox(height: 200),
                  Container(
                    color: AppColors.bgDark,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),
                        _buildHeading(),
                        const SizedBox(height: 24),
                        LabeledField(
                          label: 'Nama Lengkap',
                          child: AppTextField(
                            controller: _nameController,
                            hint: 'Masukkan nama lengkap Anda',
                            suffixIcon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LabeledField(
                          label: 'Email',
                          child: AppTextField(
                            controller: _emailController,
                            hint: 'Masukkan email Anda',
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: Icons.mail_outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LabeledField(
                          label: 'Nomor Telepon',
                          child: AppTextField(
                            controller: _phoneController,
                            hint: 'Masukkan nomor telepon Anda',
                            keyboardType: TextInputType.phone,
                            suffixIcon: Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LabeledField(
                          label: 'Jenis Pengguna',
                          child: _buildUserTypeDropdown(),
                        ),
                        const SizedBox(height: 16),
                        LabeledField(
                          label: 'Kata Sandi',
                          child: AppTextField(
                            controller: _passwordController,
                            hint: 'Masukkan kata sandi Anda',
                            obscureText: _obscurePassword,
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixTap: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTermsCheckbox(),
                        const SizedBox(height: 24),
                        _buildCreateButton(),
                        const SizedBox(height: 20),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah memiliki akun? ',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: _goToLogin,
                                child: const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.recycling,
                              color: Colors.white24,
                              size: 24,
                            ),
                            SizedBox(width: 28),
                            Icon(Icons.eco, color: Colors.white24, size: 24),
                            SizedBox(width: 28),
                            Icon(
                              Icons.park_outlined,
                              color: Colors.white24,
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTop() => SizedBox(
    height: 280,
    width: double.infinity,
    child: Image.asset(
      'assets/images/register_picture.png',
      fit: BoxFit.cover,
      width: double.infinity,
    ),
  );

  Widget _buildOverlayBrand() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Image.asset('assets/logo/ecocycle_logo.png'),
        ),
        const SizedBox(width: 8),
        const Text(
          'EcoCycle',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _buildHeading() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Buat Akun Baru',
        style: TextStyle(
          color: AppColors.textWhite,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4),
      Text(
        'Bergabunglah dengan kami di komunitas peduli lingkungan.',
        style: TextStyle(color: Colors.white54, fontSize: 14),
      ),
    ],
  );

  Widget _buildUserTypeDropdown() => Container(
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedUserType,
        isExpanded: true,
        dropdownColor: AppColors.bgCard,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primaryLight,
        ),
        style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
        items: _userTypes
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (val) {
          if (val != null) setState(() => _selectedUserType = val);
        },
      ),
    ),
  );

  Widget _buildTermsCheckbox() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 22,
        height: 22,
        child: Checkbox(
          value: _agreeToTerms,
          onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
          activeColor: AppColors.primary,
          checkColor: Colors.white,
          side: const BorderSide(color: Colors.white38),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'Saya setuju dengan '),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Syarat Layanan',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const TextSpan(text: ' dan '),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Kebijakan Privasi',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildCreateButton() => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _handleRegister,
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
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Buat Akun Baru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
    ),
  );
}
