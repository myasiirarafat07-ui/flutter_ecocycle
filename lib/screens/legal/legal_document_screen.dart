import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// Bagian dokumen legal: judul + daftar paragraf.
class LegalSection {
  final String title;
  final List<String> paragraphs;
  const LegalSection(this.title, this.paragraphs);
}

/// Layout dasar yang dipakai bersama oleh halaman Syarat Layanan & Kebijakan
/// Privasi agar konsisten dengan tema EcoCycle.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String intro;
  final String lastUpdated;
  final List<LegalSection> sections;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'EcoCycle',
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Terakhir diperbarui: $lastUpdated',
                style: TextStyle(color: context.mutedColor, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Text(
                intro,
                style: TextStyle(
                  color: context.mutedColor,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              for (final section in sections) ...[
                const SizedBox(height: 18),
                Text(
                  section.title,
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                for (final p in section.paragraphs) ...[
                  Text(
                    p,
                    style: TextStyle(
                      color: context.mutedColor,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
