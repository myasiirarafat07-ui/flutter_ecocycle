import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Pangkat loyalty bertema alam, ditentukan dari jumlah eco points pengguna.
/// Sumber kebenaran tunggal yang dipakai bersama oleh Drawer & layar Eco Points.
class EcoTier {
  final String name;
  final int minPoints;
  final Color color;
  final IconData icon;

  const EcoTier({
    required this.name,
    required this.minPoints,
    required this.color,
    required this.icon,
  });

  /// Daftar pangkat terurut dari poin terendah ke tertinggi.
  static const List<EcoTier> tiers = [
    EcoTier(
      name: 'Bibit Hijau',
      minPoints: 0,
      color: Color(0xFF84CC16), // Lime 500
      icon: Icons.grass,
    ),
    EcoTier(
      name: 'Tunas Muda',
      minPoints: 100,
      color: AppColors.primary, // Green 500
      icon: Icons.eco,
    ),
    EcoTier(
      name: 'Penjaga Alam',
      minPoints: 500,
      color: Color(0xFF0D9488), // Teal 600
      icon: Icons.forest,
    ),
    EcoTier(
      name: 'Pelindung Bumi',
      minPoints: 1500,
      color: AppColors.secondary, // Cyan 600
      icon: Icons.public,
    ),
    EcoTier(
      name: 'Pahlawan Bumi',
      minPoints: 5000,
      color: Color(0xFFF59E0B), // Amber 500
      icon: Icons.military_tech,
    ),
  ];

  /// Pangkat saat ini: pangkat tertinggi yang ambangnya sudah terpenuhi.
  static EcoTier currentFor(int points) {
    var result = tiers.first;
    for (final tier in tiers) {
      if (points >= tier.minPoints) {
        result = tier;
      }
    }
    return result;
  }

  /// Pangkat berikutnya, atau `null` bila sudah pangkat tertinggi.
  static EcoTier? nextFor(int points) {
    for (final tier in tiers) {
      if (points < tier.minPoints) {
        return tier;
      }
    }
    return null;
  }

  /// Fraksi 0..1 progres dalam rentang pangkat saat ini menuju pangkat berikutnya.
  /// Mengembalikan 1.0 bila sudah pangkat tertinggi.
  static double progressFor(int points) {
    final current = currentFor(points);
    final next = nextFor(points);
    if (next == null) return 1.0;
    final span = next.minPoints - current.minPoints;
    if (span <= 0) return 1.0;
    return ((points - current.minPoints) / span).clamp(0.0, 1.0);
  }

  /// Sisa poin menuju pangkat berikutnya (0 bila sudah pangkat tertinggi).
  static int pointsToNextFor(int points) {
    final next = nextFor(points);
    if (next == null) return 0;
    return next.minPoints - points;
  }
}
