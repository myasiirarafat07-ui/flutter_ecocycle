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
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms    = false;
  bool _isLoading       = false;

  String _selectedUserType = 'Individual / Household';
  final List<String> _userTypes = [
    'Individual / Household',
    'Petani / Farmer',
    'Bisnis / Business',
    'Organisasi / Organization',
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap setujui Terms of Service terlebih dahulu'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap lengkapi semua field yang wajib diisi'),
        backgroundColor: Colors.redAccent,
      ));
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
                        LabeledField(label: 'Full Name',
                          child: AppTextField(controller: _nameController,
                              hint: 'John Doe', suffixIcon: Icons.person_outline)),
                        const SizedBox(height: 16),
                        LabeledField(label: 'Email Address',
                          child: AppTextField(controller: _emailController,
                              hint: 'hello@example.com',
                              keyboardType: TextInputType.emailAddress,
                              suffixIcon: Icons.mail_outline)),
                        const SizedBox(height: 16),
                        LabeledField(label: 'Phone Number',
                          child: AppTextField(controller: _phoneController,
                              hint: '+62 8xx xxxx xxxx',
                              keyboardType: TextInputType.phone,
                              suffixIcon: Icons.phone_outlined)),
                        const SizedBox(height: 16),
                        LabeledField(label: 'User Type', child: _buildUserTypeDropdown()),
                        const SizedBox(height: 16),
                        LabeledField(label: 'Password',
                          child: AppTextField(controller: _passwordController,
                              hint: '••••••••', obscureText: _obscurePassword,
                              suffixIcon: _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword))),
                        const SizedBox(height: 20),
                        _buildTermsCheckbox(),
                        const SizedBox(height: 24),
                        _buildCreateButton(),
                        const SizedBox(height: 20),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account? ',
                                  style: TextStyle(color: Colors.white54, fontSize: 14)),
                              GestureDetector(
                                onTap: _goToLogin,
                                child: const Text('Login',
                                    style: TextStyle(color: AppColors.primaryLight,
                                        fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.recycling, color: Colors.white24, size: 24),
                            SizedBox(width: 28),
                            Icon(Icons.eco, color: Colors.white24, size: 24),
                            SizedBox(width: 28),
                            Icon(Icons.park_outlined, color: Colors.white24, size: 24),
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
    height: 280, width: double.infinity,
    child: Image.asset('assets/images/register_picture.png',
        fit: BoxFit.cover, width: double.infinity),
  );

  Widget _buildOverlayBrand() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Row(children: [
      SizedBox(width: 22, height: 22,
          child: Image.asset('assets/logo/ecocycle_logo.png')),
      const SizedBox(width: 8),
      const Text('EcoCycle', style: TextStyle(color: AppColors.textWhite,
          fontSize: 18, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _buildHeading() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Create Account', style: TextStyle(color: AppColors.textWhite,
          fontSize: 26, fontWeight: FontWeight.bold)),
      SizedBox(height: 4),
      Text('Join our community of eco-conscious heroes.',
          style: TextStyle(color: Colors.white54, fontSize: 14)),
    ],
  );

  Widget _buildUserTypeDropdown() => Container(
    decoration: BoxDecoration(color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12)),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedUserType, isExpanded: true,
        dropdownColor: AppColors.bgCard,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryLight),
        style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
        items: _userTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (val) { if (val != null) setState(() => _selectedUserType = val); },
      ),
    ),
  );

  Widget _buildTermsCheckbox() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 22, height: 22,
        child: Checkbox(
          value: _agreeToTerms,
          onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
          activeColor: AppColors.primary, checkColor: Colors.white,
          side: const BorderSide(color: Colors.white38),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
            children: [
              const TextSpan(text: 'I agree to the '),
              WidgetSpan(child: GestureDetector(onTap: () {},
                  child: const Text('Terms of Service',
                      style: TextStyle(color: AppColors.primaryLight, fontSize: 13)))),
              const TextSpan(text: ' and '),
              WidgetSpan(child: GestureDetector(onTap: () {},
                  child: const Text('Privacy Policy',
                      style: TextStyle(color: AppColors.primaryLight, fontSize: 13)))),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildCreateButton() => SizedBox(
    width: double.infinity, height: 54,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _handleRegister,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
    ),
  );
}