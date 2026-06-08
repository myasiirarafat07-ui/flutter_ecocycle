import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/point_api_service.dart';

class EcoPointsScreen extends StatefulWidget {
  const EcoPointsScreen({super.key});

  @override
  State<EcoPointsScreen> createState() => _EcoPointsScreenState();
}

class _EcoPointsScreenState extends State<EcoPointsScreen> {
  final PointApiService _api = PointApiService();
  PointsSummary? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = context.read<UserProvider>().token;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await _api.getPoints(token);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
      // Sinkronkan saldo terbaru ke provider.
      context.read<UserProvider>().setEcoPoints(summary.balance);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: context.textColor, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Eco Points',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: context.mutedColor, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.mutedColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = _summary!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _buildBalanceCard(context, summary),
          const SizedBox(height: 20),
          _buildImpactRow(context, summary),
          const SizedBox(height: 24),
          Text(
            'Riwayat Poin',
            style: TextStyle(
              color: context.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (summary.transactions.isEmpty)
            _buildEmpty(context)
          else
            ...summary.transactions.map((t) => _buildTxTile(context, t)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, PointsSummary s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Saldo Eco Points',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${s.balance}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'poin',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow(BuildContext context, PointsSummary s) {
    return Row(
      children: [
        _impactCard(context, Icons.delete_sweep_outlined,
            '${s.totalWasteKg.toStringAsFixed(1)} kg', 'Sampah'),
        const SizedBox(width: 12),
        _impactCard(context, Icons.park_outlined, '${s.treesPlanted}', 'Pohon'),
        const SizedBox(width: 12),
        _impactCard(context, Icons.cloud_outlined,
            '${s.co2OffsetKg.toStringAsFixed(1)} kg', 'CO₂'),
      ],
    );
  }

  Widget _impactCard(
      BuildContext context, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: context.textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: context.mutedColor, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.history, color: context.dividerColor, size: 44),
          const SizedBox(height: 10),
          Text(
            'Belum ada riwayat poin.\nMulai belanja untuk mengumpulkan poin!',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.mutedColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTxTile(BuildContext context, PointTransaction t) {
    final isEarn = t.type == 'EARN' || t.points >= 0;
    final date = t.createdAt;
    final dateStr = date == null
        ? ''
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEarn ? Icons.add : Icons.remove,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.description,
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(color: context.mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isEarn ? '+' : ''}${t.points}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
