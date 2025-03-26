import 'dart:convert';

import 'package:final_canteen/model/user_model.dart';
import 'package:final_canteen/model/user_role_model.dart';
import 'package:http/http.dart' as http;

class UserApiServices {
  final String apiUrl = 'http://localhost:5001/api/User';

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/DisplayAllUser"));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load users, status code: ${response.statusCode}');
      }

      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      final decodedData = json.decode(response.body);

      List<dynamic> usersJson;
      if (decodedData is Map<String, dynamic>) {
        usersJson = decodedData['users'] ?? [];
      } else if (decodedData is List) {
        usersJson = decodedData;
      } else {
        throw Exception('Unexpected API response format');
      }

      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<User> fetchUserById(String userId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/GetUserByID/$userId'));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load user, status code: ${response.statusCode}');
      }
      
      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }
      
      final jsonResponse = json.decode(response.body);
      
      if (jsonResponse['isSuccess'] == true && jsonResponse.containsKey('data')) {
        final userData = jsonResponse['data'];
        return User.fromJson(userData);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to retrieve user');
      }
    } catch (e) {
      print('Error fetching user by ID: $e');
      throw Exception('Error fetching user: $e');
    }
  }

  Future<List<UserRole>> fetchUsersRole() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/DisplayUserRole"));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load users, status code: ${response.statusCode}');
      }

      if (response.body.isEmpty) {
        return [];
      }

      final decodedData = json.decode(response.body);

      if (decodedData is Map<String, dynamic>) {
        if (decodedData.containsKey('data') && decodedData['data'] is List) {
          List<UserRole> usersJson = List<UserRole>.from(
              decodedData['data'].map((x) => UserRole.fromJson(x)));
          return usersJson;
        } else {
          throw Exception('Missing or incorrect "data" key in response');
        }
      } else {
        throw Exception('Unexpected API response format');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  Future<bool> addUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5001/api/User/CreateUpdateUser"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String newRoleId) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl/UpdateUserRole"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "userId": userId,
          "newRoleId": newRoleId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update user role');
      }
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }
}
