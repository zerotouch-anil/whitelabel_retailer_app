class RetailerHistoryData {
  final String id;
  final String transactionId;
  final String? warrantyKey;
  final String transactionType;
  final int amount;
  final String? notes;
  final CustomerDetails? customerDetails;
  final DateTime transactionDate;
  final String bonusAmount;
  final String bonusPercentage;
  final DateTime createdAt;
  final FromUser? fromUser;

  RetailerHistoryData({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    required this.bonusAmount,
    required this.bonusPercentage,
    required this.createdAt,
    this.warrantyKey,
    this.notes,
    this.customerDetails,
    this.fromUser,
  });

  factory RetailerHistoryData.fromJson(Map<String, dynamic> json) {
    final amt = json['amount'];

    return RetailerHistoryData(
      id: json['_id']?.toString() ?? '',
      transactionId: json['transactionId']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? '',
      amount:
          amt is int
              ? amt
              : amt is double
              ? amt.round()
              : int.tryParse(amt?.toString() ?? '0') ?? 0,
      warrantyKey: json['warrantyKey']?.toString(),
      notes: json['notes']?.toString(),
      transactionDate:
          DateTime.tryParse(json['transactionDate']?.toString() ?? '') ??
          DateTime.now(),
      bonusAmount: json['bonusAmount']?.toString() ?? '0',
      bonusPercentage: json['bonusPercentage']?.toString() ?? '0',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      customerDetails:
          (json['customerDetails'] is Map<String, dynamic>)
              ? CustomerDetails.fromJson(json['customerDetails'])
              : null,
      fromUser:
          (json['fromUser'] is Map<String, dynamic>)
              ? FromUser.fromJson(json['fromUser'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'transactionId': transactionId,
      'transactionType': transactionType,
      'amount': amount,
      'warrantyKey': warrantyKey,
      'notes': notes,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'customerDetails': customerDetails?.toJson(),
      'fromUser': fromUser?.toJson(),
    };
  }
}

class CustomerDetails {
  final String? customerId;
  final String customerName;
  final String productModel;
  final int premiumAmount;

  CustomerDetails({
    this.customerId,
    required this.customerName,
    required this.productModel,
    required this.premiumAmount,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    final amount = json['premiumAmount'];

    return CustomerDetails(
      customerId: json['customerId']?.toString(),
      customerName: json['customerName']?.toString() ?? '',
      productModel: json['productModel']?.toString() ?? '',
      premiumAmount:
          amount is int
              ? amount
              : amount is double
              ? amount.round()
              : int.tryParse(amount?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'productModel': productModel,
      'premiumAmount': premiumAmount,
    };
  }
}

class FromUser {
  final String id;
  final String userId;
  final String userType;
  final String name;

  FromUser({
    required this.id,
    required this.userId,
    required this.userType,
    required this.name,
  });

  factory FromUser.fromJson(Map<String, dynamic> json) {
    return FromUser(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userType: json['userType']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'userId': userId, 'userType': userType, 'name': name};
  }
}

class HistoryPaginationData {
  final int currentPage;
  final int totalPages;
  final int totalData;
  final int limit;

  HistoryPaginationData({
    required this.currentPage,
    required this.totalPages,
    required this.totalData,
    required this.limit,
  });

  factory HistoryPaginationData.fromJson(Map<String, dynamic> json) {
    return HistoryPaginationData(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalData: json['totalData'],
      limit: json['limit'],
    );
  }
}

class HistoryAndPaginationResponse {
  final List<RetailerHistoryData> retailerHistory;
  final HistoryPaginationData historyPagination;

  HistoryAndPaginationResponse({
    required this.retailerHistory,
    required this.historyPagination,
  });

  factory HistoryAndPaginationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    final retailerHistory =
        (data['history'] as List)
            .map((e) => RetailerHistoryData.fromJson(e))
            .toList();

    final historyPagination = HistoryPaginationData.fromJson(
      data['pagination'],
    );

    return HistoryAndPaginationResponse(
      retailerHistory: retailerHistory,
      historyPagination: historyPagination,
    );
  }
}
