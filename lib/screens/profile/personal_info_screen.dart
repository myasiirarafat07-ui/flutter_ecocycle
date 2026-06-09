import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_api_service.dart';
import '../../widgets/profile_avatar.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _hasChanges = false;
  final AuthApiService _authApi = AuthApiService();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);

    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _addressController,
    ]) {
      c.addListener(_onChanged);
    }
  }

  void _onChanged() {
    final user = context.read<UserProvider>();
    final changed =
        _nameController.text != user.name ||
        _emailController.text != user.email ||
        _phoneController.text != user.phone ||
        _addressController.text != user.address;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _saving = false;

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan email tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    setState(() => _saving = true);

    try {
      final updated = await _authApi.updateProfile(
        token: userProvider.token,
        fullName: name,
        email: email,
        phoneNumber: phone,
        address: address,
      );

      if (!mounted) return;
      userProvider.applyUpdatedUser(updated);
      setState(() {
        _hasChanges = false;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Informasi berhasil disimpan'),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showEditDialog({
    required String title,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final tempController = TextEditingController(text: controller.text);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Edit $title',
          style: TextStyle(
            color: context.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: context.surfaceAltColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.dividerColor),
          ),
          child: TextField(
            controller: tempController,
            keyboardType: keyboardType,
            maxLines: maxLines,
            autofocus: true,
            style: TextStyle(color: context.textColor, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Masukkan $title',
              hintStyle: TextStyle(color: context.mutedColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: context.mutedColor)),
          ),
          TextButton(
            onPressed: () {
              controller.text = tempController.text;
              Navigator.pop(ctx);
            },
            child: Text(
              'Simpan',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    _buildAvatar(user),
                    const SizedBox(height: 16),
                    _buildUserName(user),
                    const SizedBox(height: 6),
                    _buildBadge(),
                    const SizedBox(height: 32),
                    _buildSectionLabel('INFORMASI AKUN'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      label: 'NAMA LENGKAP',
                      value: _nameController.text.isEmpty
                          ? '-'
                          : _nameController.text,
                      onEdit: () => _showEditDialog(
                        title: 'Nama',
                        controller: _nameController,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.mail_outline,
                      label: 'EMAIL',
                      value: _emailController.text.isEmpty
                          ? '-'
                          : _emailController.text,
                      onEdit: () => _showEditDialog(
                        title: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'NOMOR TELEPON',
                      value: _phoneController.text.isEmpty
                          ? 'Belum diisi'
                          : _phoneController.text,
                      onEdit: () => _showEditDialog(
                        title: 'Nomor Telepon',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'ALAMAT PENGIRIMAN',
                      value: _addressController.text.isEmpty
                          ? 'Belum diisi'
                          : _addressController.text,
                      onEdit: () => _showEditDialog(
                        title: 'Alamat',
                        controller: _addressController,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: context.textColor,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Informasi Pribadi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48), // balance
        ],
      ),
    );
  }

  Widget _buildAvatar(UserProvider user) {
    return ProfileAvatar(
      user: user,
      size: 110,
      showCameraBadge: true,
      onTap: () => pickAndUploadProfilePhoto(context, user),
    );
  }

  Widget _buildUserName(UserProvider user) {
    return Text(
      user.name.isEmpty ? 'Pengguna' : user.name,
      style: TextStyle(
        color: context.textColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBadge() {
    const badgeLabel = 'Member EcoCycle';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shield_outlined, color: AppColors.primary, size: 15),
        const SizedBox(width: 5),
        Text(
          badgeLabel,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: context.mutedColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: value == 'Belum diisi'
                        ? context.mutedColor
                        : context.textColor,
                    fontSize: 15,
                    fontStyle: value == 'Belum diisi'
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.edit_outlined,
                color: context.mutedColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: (_hasChanges && !_saving) ? _saveChanges : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasChanges ? AppColors.primary : context.surfaceColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: context.surfaceColor,
            disabledForegroundColor: context.mutedColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_outlined, size: 20),
          label: Text(
            _saving
                ? 'Menyimpan...'
                : (_hasChanges ? 'Simpan Perubahan' : 'Tidak Ada Perubahan'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
