import 'dart:convert';
import 'package:final_canteen/model/role_model.dart';
import 'package:http/http.dart' as http;

class RoleApiService {
  final String apiUrl = 'http://localhost:5001/api/Role';

  Future<Roles> fetchRoles() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/GetRoles"));

      if (response.statusCode != 200) {
        throw Exception('Failed to load roles, status code: ${response.statusCode}');
      }

      final decodedData = json.decode(response.body);
      return Roles.fromJson(decodedData);
    } catch (e) {
      throw Exception('Error fetching roles: $e');
    }
  }
}
