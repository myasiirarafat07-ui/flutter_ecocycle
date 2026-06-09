import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../providers/user_provider.dart';

/// Decode foto base64 (mendukung prefix data-URL). Mengembalikan `null` bila
/// kosong atau gagal didekode.
Uint8List? decodeProfilePhoto(String raw) {
  if (raw.isEmpty) return null;
  try {
    var data = raw;
    if (data.startsWith('data:')) {
      final comma = data.indexOf(',');
      if (comma != -1) data = data.substring(comma + 1);
    }
    return base64Decode(data);
  } catch (_) {
    return null;
  }
}

/// Lingkaran avatar yang menampilkan foto profil (base64) bila ada, atau
/// fallback ke huruf pertama nama / ikon orang. Dipakai bersama di halaman
/// profil, informasi pribadi, dan drawer.
class ProfileAvatar extends StatelessWidget {
  final UserProvider user;
  final double size;

  /// Tampilkan badge kamera kecil di pojok kanan bawah (penanda bisa diganti).
  final bool showCameraBadge;

  /// Bila diberikan, seluruh avatar bisa di-tap (mis. untuk ganti foto).
  final VoidCallback? onTap;

  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Color? initialColor;

  const ProfileAvatar({
    super.key,
    required this.user,
    this.size = 110,
    this.showCameraBadge = false,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 3,
    this.initialColor,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = decodeProfilePhoto(user.photo);
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? AppColors.primary,
          width: borderWidth,
        ),
        color: backgroundColor ?? context.surfaceColor,
      ),
      child: ClipOval(
        child: bytes != null
            ? Image.memory(
                bytes,
                width: size,
                height: size,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => _fallback(context, initial),
              )
            : _fallback(context, initial),
      ),
    );

    final content = showCameraBadge
        ? Stack(
            children: [
              circle,
              Positioned(
                right: 0,
                bottom: 4,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.bgColor, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ],
          )
        : circle;

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }

  Widget _fallback(BuildContext context, String initial) {
    if (user.name.isEmpty) {
      return Icon(Icons.person, color: context.mutedColor, size: size * 0.55);
    }
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: initialColor ?? AppColors.primary,
          fontSize: size * 0.36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Alur ganti foto profil: tampilkan pilihan (galeri / kamera / hapus),
/// ambil gambar, encode base64, lalu unggah lewat [UserProvider.changePhoto].
Future<void> pickAndUploadProfilePhoto(
  BuildContext context,
  UserProvider user,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final hasPhoto = user.photo.isNotEmpty;

  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ctx.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Ubah Foto Profil',
              style: TextStyle(
                color: ctx.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: AppColors.primary),
            title: Text('Pilih dari Galeri',
                style: TextStyle(color: ctx.textColor)),
            onTap: () => Navigator.pop(ctx, 'gallery'),
          ),
          ListTile(
            leading:
                const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
            title:
                Text('Ambil dari Kamera', style: TextStyle(color: ctx.textColor)),
            onTap: () => Navigator.pop(ctx, 'camera'),
          ),
          if (hasPhoto)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('Hapus Foto',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () => Navigator.pop(ctx, 'remove'),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (action == null) return;

  try {
    if (action == 'remove') {
      await user.changePhoto(null);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Foto profil dihapus'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final source =
        action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (picked == null) return; // dibatalkan pengguna

    final bytes = await picked.readAsBytes();
    final base64Photo = base64Encode(bytes);

    await user.changePhoto(base64Photo);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Foto profil diperbarui'),
        backgroundColor: AppColors.primary,
      ),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('Gagal memperbarui foto: $e'),
        backgroundColor: AppColors.danger,
      ),
    );
  }
}
