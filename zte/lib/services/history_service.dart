import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eWarranty/constants/config.dart';
import 'package:eWarranty/models/history_model.dart';
import 'package:eWarranty/utils/shared_preferences.dart';

Future<Map<String, String>> _getAuthHeaders() async {
  final token = SharedPreferenceHelper.instance.getString(
    'token',
  );
  return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
}

Future<HistoryAndPaginationResponse> fetchRetailerHistoryData(filter) async {
  final userId = SharedPreferenceHelper.instance.getString('userId');
  print('userIdD: $userId');
  filter["userId"] = userId;
  
  final url = Uri.parse('${baseUrl}api/wallet/history');

  try {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(filter),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return HistoryAndPaginationResponse.fromJson(jsonData);
    } else {
      print('Failed to fetch History data: ${response.body}');
      throw Exception('Failed to fetch History data');
    }
  } catch (e) {
    print('Error fetching History Data: $e');
    rethrow;
  }
}
