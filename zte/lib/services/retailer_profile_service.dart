import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eWarranty/constants/config.dart';
import 'package:eWarranty/models/retailer_profile_model.dart';
import 'package:eWarranty/utils/shared_preferences.dart';

Future<Map<String, String>> _getAuthHeaders() async {
  final token = SharedPreferenceHelper.instance.getString('token');
  return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
}

Future<RetailerProfile> fetchRetailerProfile() async {
  final url = Uri.parse('${baseUrl}api/auth/me');

  try {
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final userJson = responseData['data']['user'];
      final user = RetailerProfile.fromJson(userJson);
      print("user:: $userJson");

      return user;
    } else {
      print('Failed to fetch Profile data: ${response.body}');
      throw Exception('Failed to fetch Profile data');
    }
  } catch (e) {
    print('Error fetching Profile Data: $e');
    rethrow;
  }
}

Future<void> changeRetailerPassword(
  currentPassword,
  newPassword,
  confirmPassword,
) async {
  final url = Uri.parse('${baseUrl}api/auth/change-password');

  try {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print("pswd: $responseData");
    } else {
      print('Failed to change password: ${response.body}');
      throw Exception('Failed to change password');
    }
  } catch (e) {
    print('Error changing password: $e');
    rethrow;
  }
}
