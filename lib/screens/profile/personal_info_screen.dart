import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';

// ============================================================
// PERSONAL INFORMATION SCREEN
// Menampilkan & memungkinkan edit data pribadi user
// ============================================================
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

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameController    = TextEditingController(text: user.name);
    _emailController   = TextEditingController(text: user.email);
    _phoneController   = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);

    // Pantau perubahan
    for (final c in [_nameController, _emailController, _phoneController, _addressController]) {
      c.addListener(_onChanged);
    }
  }

  void _onChanged() {
    final user = context.read<UserProvider>();
    final changed =
        _nameController.text    != user.name    ||
        _emailController.text   != user.email   ||
        _phoneController.text   != user.phone   ||
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

  void _saveChanges() {
    final name    = _nameController.text.trim();
    final email   = _emailController.text.trim();
    final phone   = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nama dan email tidak boleh kosong'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    context.read<UserProvider>().updatePersonalInfo(
      name: name,
      email: email,
      phone: phone,
      address: address,
    );

    setState(() => _hasChanges = false);

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
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Edit $title',
          style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D2A0D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: tempController,
            keyboardType: keyboardType,
            maxLines: maxLines,
            autofocus: true,
            style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Masukkan $title',
              hintStyle: const TextStyle(color: Colors.white30),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              controller.text = tempController.text;
              Navigator.pop(ctx);
            },
            child: Text('Simpan', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
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
                      value: _nameController.text.isEmpty ? '-' : _nameController.text,
                      onEdit: () => _showEditDialog(title: 'Nama', controller: _nameController),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.mail_outline,
                      label: 'EMAIL',
                      value: _emailController.text.isEmpty ? '-' : _emailController.text,
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
                      value: _phoneController.text.isEmpty ? 'Belum diisi' : _phoneController.text,
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
                      value: _addressController.text.isEmpty ? 'Belum diisi' : _addressController.text,
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
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Informasi Pribadi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite,
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
    return Stack(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
            color: AppColors.bgCard,
          ),
          child: ClipOval(
            child: user.name.isNotEmpty
                ? Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white54, size: 60),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 4,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ganti foto segera hadir'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bgDark, width: 2),
              ),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 17),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserName(UserProvider user) {
    return Text(
      user.name.isEmpty ? 'Pengguna' : user.name,
      style: const TextStyle(
        color: AppColors.textWhite,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shield_outlined, color: AppColors.primaryLight, size: 15),
        const SizedBox(width: 5),
        Text(
          'Eco-conscious Member',
          style: TextStyle(
            color: AppColors.primaryLight,
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
        style: const TextStyle(
          color: Colors.white38,
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
        color: AppColors.bgCard,
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
                    color: AppColors.primaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: value == 'Belum diisi' ? Colors.white38 : AppColors.textWhite,
                    fontSize: 15,
                    fontStyle: value == 'Belum diisi' ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.edit_outlined, color: Colors.white38, size: 20),
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
          onPressed: _hasChanges ? _saveChanges : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasChanges ? AppColors.primary : AppColors.bgCard,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.bgCard,
            disabledForegroundColor: Colors.white38,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          icon: const Icon(Icons.save_outlined, size: 20),
          label: Text(
            _hasChanges ? 'Save Changes' : 'No Changes',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}