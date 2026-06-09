import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Menampilkan gambar produk dari URL absolut (http/https), path relatif file
/// terunggah (mis. `/uploads/products/x.jpg` → dilengkapi base URL API), atau
/// data base64 (pola sama dengan foto profil). Fallback ke ikon bila kosong,
/// gagal didekode, atau gagal dimuat.
class ProductImage extends StatelessWidget {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();

    Widget fallback() => Container(
          width: width,
          height: height,
          color: context.surfaceAltColor,
          child: Icon(
            Icons.image_not_supported,
            color: context.mutedColor,
            size: iconSize,
          ),
        );

    if (url.isEmpty) return fallback();

    final isRemote = url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/');
    if (isRemote) {
      final src = url.startsWith('/') ? '$_baseUrl$url' : url;
      return Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    final bytes = _decodeBase64(url);
    if (bytes == null) return fallback();
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  static Uint8List? _decodeBase64(String raw) {
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
}
