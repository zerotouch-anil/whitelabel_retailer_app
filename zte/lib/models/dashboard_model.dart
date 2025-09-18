class DashboardData {
  final bool success;
  final WalletBalance walletBalance;
  final EWarrantyStats eWarrantyStats;
  final int totalCustomersCount;
  final List<Customer> customers;

  DashboardData({
    required this.success,
    required this.walletBalance,
    required this.eWarrantyStats,
    required this.totalCustomersCount,
    required this.customers,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      success: json['success'] ?? false,
      walletBalance: WalletBalance.fromJson(json['walletBalance']),
      eWarrantyStats: EWarrantyStats.fromJson(json['eWarrantyStats']),
      totalCustomersCount: json['totalCustomersCount'] ?? 0,
      customers:
          (json['customers'] as List).map((e) => Customer.fromJson(e)).toList(),
    );
  }
}

class WalletBalance {
  final int remainingAmount;

  WalletBalance({required this.remainingAmount});

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    final remaining = json['remainingAmount'];

    return WalletBalance(
      remainingAmount:
          remaining is int
              ? remaining
              : remaining is double
              ? remaining.round()
              : 0,
    );
  }
}
class EWarrantyStats {
  final int totalWarranties;
  final int activeWarranties;
  final int expiredWarranties;
  final int claimedWarranties;
  final int totalPremiumCollected;
  final DateTime? lastWarrantyDate;

  EWarrantyStats({
    required this.totalWarranties,
    required this.activeWarranties,
    required this.expiredWarranties,
    required this.claimedWarranties,
    required this.totalPremiumCollected,
    this.lastWarrantyDate,
  });

  factory EWarrantyStats.fromJson(Map<String, dynamic> json) {
    final totalPremium = json['totalPremiumCollected'];

    return EWarrantyStats(
      totalWarranties: json['totalWarranties'] ?? 0,
      activeWarranties: json['activeWarranties'] ?? 0,
      expiredWarranties: json['expiredWarranties'] ?? 0,
      claimedWarranties: json['claimedWarranties'] ?? 0,
      totalPremiumCollected: totalPremium is int
          ? totalPremium
          : totalPremium is double
              ? totalPremium.round()
              : 0,
      lastWarrantyDate: json['lastWarrantyDate'] != null
          ? DateTime.tryParse(json['lastWarrantyDate'])
          : null,
    );
  }
}


class Customer {
  final String customerId;
  final String customerName;
  final String modelName;
  final int warrantyPeriod;
  final dynamic premiumAmount;
  final DateTime createdDate;
  final String warrantyKey;
  final String category;
  final String planId;
  final String? notes;

  Customer({
    required this.customerId,
    required this.customerName,
    required this.modelName,
    required this.warrantyPeriod,
    required this.premiumAmount,
    required this.createdDate,
    required this.warrantyKey,
    required this.category,
    required this.planId,
    this.notes,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      modelName: json['modelName'] ?? '',
      warrantyPeriod: json['warrantyPeriod'] ?? '',
      premiumAmount: json['premiumAmount'],
      createdDate: DateTime.parse(json['createdDate']),
      warrantyKey: json['warrantyKey'] ?? '',
      category: json['category'] ?? '',
      planId: json['planId'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}
