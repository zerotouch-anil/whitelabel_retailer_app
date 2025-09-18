import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eWarranty/constants/config.dart';
import 'package:eWarranty/models/brands_model.dart';
import 'package:eWarranty/models/categories_model.dart';
import 'package:eWarranty/utils/shared_preferences.dart';



Future<Map<String, String>> _getAuthHeaders() async {
  final token = SharedPreferenceHelper.instance.getString('token');
  return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
}

Future<List<Categories>> fetchCategories() async {
  final url = Uri.parse('${baseUrl}api/categories/categories');

  try {
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      debugPrint("jsonListCate: $jsonList", wrapWidth: 1024);

      return jsonList.map((json) => Categories.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch categories. Status: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('Error fetching categories: $e');
    rethrow;
  }
}

Future<List<Brand>> fetchBrands(String categoryId) async {
  final url = Uri.parse('${baseUrl}api/brands/brands');

  try {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'categoryId': categoryId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Brand.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch brands. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching brands: $e');
    rethrow;
  }
}
