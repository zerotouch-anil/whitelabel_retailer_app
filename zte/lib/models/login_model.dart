class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final Map<String, dynamic>? user;
  final String? token;

  LoginData({
    this.user,
    this.token,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: json['user'] as Map<String, dynamic>?,
      token: json['token'] as String?,
    );
  }
}