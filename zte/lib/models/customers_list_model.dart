class CustomersData {
  final String name;
  final String modelName;
  final String planId;
  final int premiumAmount; 
  final String warrantyKey;
  final String customerId;
  final DateTime createdDate;
  final String category;
  final bool isActive;
  final int warrantyPeriod;
  final String? notes;

  CustomersData({
    required this.name,
    required this.modelName,
    required this.planId,
    required this.premiumAmount,
    required this.warrantyKey,
    required this.customerId,
    required this.createdDate,
    required this.category,
    required this.isActive,
    required this.warrantyPeriod,
    this.notes,
  });

  factory CustomersData.fromJson(Map<String, dynamic> json) {
    final premium = json['warrantyDetails']['premiumAmount'];

    return CustomersData(
      name: json['customerDetails']['name'] ?? '',
      modelName: json['productDetails']['modelName'] ?? '',
      planId: json['warrantyDetails']['planId'] ?? '',
      premiumAmount: premium is int
          ? premium
          : premium is double
              ? premium.round()
              : 0,
      warrantyKey: json['warrantyKey'] ?? '',
      customerId: json['customerId']?.toString() ?? '',
      createdDate: DateTime.parse(json['dates']['createdDate']),
      category: json['productDetails']['category'] ?? '',
      isActive: json['isActive'] ?? false,
      warrantyPeriod: json['warrantyDetails']['warrantyPeriod'] ?? 0,
      notes: json['notes'],
    );
  }
}


class PaginationData {
  final int currentPage;
  final int totalPages;
  final int totalData;
  final int limit;

  PaginationData({
    required this.currentPage,
    required this.totalPages,
    required this.totalData,
    required this.limit,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalData: json['totalData'],
      limit: json['limit'],
    );
  }
}


class CustomerListResponse {
  final List<CustomersData> customers;
  final PaginationData pagination;

  CustomerListResponse({
    required this.customers,
    required this.pagination,
  });

  factory CustomerListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    final customersList = (data['customers'] as List)
        .map((e) => CustomersData.fromJson(e))
        .toList();

    final pagination = PaginationData.fromJson(data['pagination']);

    return CustomerListResponse(
      customers: customersList,
      pagination: pagination,
    );
  }
}
