import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:eWarranty/constants/config.dart';
import 'package:eWarranty/utils/shared_preferences.dart';

const String uploadEndpoint = 'api/customers/handle-file';

Future<Map<String, String>> _getAuthHeaders() async {
  final token = await SharedPreferenceHelper.instance.getString(
    'token',
  );
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

Future<String?> uploadFile(File file) async {
  try {
    final headers = await _getAuthHeaders();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$uploadEndpoint'),
    );

    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['mode'] = 'upload';

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseBody);
      String relativePath = jsonResponse['message'];
      return relativePath;
    } else {
      print('Upload failed: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
}

Future<bool> deleteFile(String fileUrl) async {
  try {
    final headers = await _getAuthHeaders();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$uploadEndpoint'),
    );

    request.headers.addAll(headers);
    request.fields['mode'] = 'delete';
    request.fields['deleteFile'] = fileUrl;

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseBody);
      return jsonResponse['message'] == 'deleted';
    } else {
      print('Delete failed: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Delete error: $e');
    return false;
  }
}
