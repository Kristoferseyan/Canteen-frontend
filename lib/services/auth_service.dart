import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:final_canteen/providers/user_provider.dart';

class AuthService {
  final String baseUrl = "http://localhost:5001/api/auth/login"; 

  Future<bool> login(String username, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];

        await _saveToken(token, context); 
        return true;
      } else {
        print("Login failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception during login: $e");
      return false;
    }
  }

  Future<void> _saveToken(String token, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", token);

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print("Decoded Token: $decodedToken");

      String? userId = decodedToken['userId'];
      String? role = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']; 

      print("Extracted UserId: $userId");
      print("Extracted Role: $role");

      if (userId != null) {
        await prefs.setString("userId", userId);
        
        try {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.setUserId(userId);
          print("UserProvider updated with userId: $userId");
        } catch (e) {
          print("Error updating UserProvider: $e");
        }
      } else {
        print("Error: `userId` not found in token!");
      }

      if (role != null) {
        await prefs.setString("role", role);
      } else {
        print("Error: `role` not found in token!");
      }

      if (role == 'staff') {
        Navigator.pushReplacementNamed(context, '/staff_dashboard');
      } else if (role == 'employee') {
        Navigator.pushReplacementNamed(context, '/employee_dashboard');
      } else if(role == 'admin'){
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        print("Error: Invalid role: $role");
      }
    } catch (e) {
      print("Error saving token or navigating: $e");
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  Future<bool> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove("jwt_token"),
        prefs.remove("userId"),
        prefs.remove("role"),
      ]);
      
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.logout(); 
        print("UserProvider updated for logout");
      } catch (e) {
        print("Error updating UserProvider during logout: $e");
      }
      
      await Navigator.pushNamedAndRemoveUntil(
        context,
        '/landingpage',
        (route) => false,
      );
      
      return true;
    } catch (e) {
      print("Error during logout: $e");
      return false;
    }
  }

  Future<void> refreshUserDataFromPrefs(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      
      if (userId != null && userId.isNotEmpty) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUserId(userId);
        print("Refreshed UserProvider from SharedPreferences");
      }
    } catch (e) {
      print("Error refreshing user data: $e");
    }
  }
}
