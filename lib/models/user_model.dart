class UserModel {
  final String name;
  final String memberSince;
  final bool isPremium;
  final double totalWasteKg;
  final double weeklyChangePercent;
  final int treesPlanted;
  final double co2OffsetKg;

  const UserModel({
    required this.name,
    required this.memberSince,
    required this.isPremium,
    required this.totalWasteKg,
    required this.weeklyChangePercent,
    required this.treesPlanted,
    required this.co2OffsetKg,
  });
}

class ActivityItem {
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;

  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
  });
}
