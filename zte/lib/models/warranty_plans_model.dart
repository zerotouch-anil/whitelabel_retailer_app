class WarrantyPlans {
  final String id;
  final String planId;
  final String companyId;
  final String planName;
  final String planDescription;
  final int duration;
  final int premiumAmount;
  final List<String> eligibleCategories;
  final DateTime createdAt;

  WarrantyPlans({
    required this.id,
    required this.planId,
    required this.companyId,
    required this.planName,
    required this.planDescription,
    required this.duration,
    required this.premiumAmount,
    required this.eligibleCategories,
    required this.createdAt,
  });

  factory WarrantyPlans.fromJson(Map<String, dynamic> json) {
    final premium = json['premiumAmount'];

    return WarrantyPlans(
      id: json['_id'] ?? '',
      planId: json['planId'] ?? '',
      companyId: json['companyId'] ?? '',
      planName: json['planName'] ?? '',
      planDescription: json['planDescription'] ?? '',
      duration: json['duration'] ?? 0,
      premiumAmount:
          premium is int
              ? premium
              : premium is double
              ? premium.round()
              : int.tryParse(premium?.toString() ?? '0') ?? 0,
      eligibleCategories: List<String>.from(json['eligibleCategories'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
