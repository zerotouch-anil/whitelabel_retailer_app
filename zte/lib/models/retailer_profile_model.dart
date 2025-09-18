class RetailerProfile {
  final Address address;
  final WalletBalance walletBalance;
  final String userType;
  final String name;
  final String email;
  final String phone;
  final String alternatePhone;
  final ParentUser parentUser;

  RetailerProfile({
    required this.address,
    required this.walletBalance,
    required this.userType,
    required this.name,
    required this.email,
    required this.phone,
    required this.alternatePhone,
    required this.parentUser,
  });

  factory RetailerProfile.fromJson(Map<String, dynamic> json) {
    return RetailerProfile(
      address: Address.fromJson(json['address']),
      walletBalance: WalletBalance.fromJson(json['walletBalance']),
      userType: json['userType'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      alternatePhone: json['alternatePhone'] ?? '',
      parentUser: ParentUser.fromJson(json['parentUser']),
    );
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipCode;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipCode: json['zipCode'] ?? '',
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
              : int.tryParse(remaining?.toString() ?? '0') ?? 0,
    );
  }
}

class ParentUser {
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String userType;

  ParentUser({
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.userType,
  });

  factory ParentUser.fromJson(Map<String, dynamic> json) {
    return ParentUser(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      userType: json['userType'] ?? '',
    );
  }
}
