import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  String? get userId => _userId;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userId != null;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  UserProvider() {
    loadUserId();
  }

  Future<void> loadUserId() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final loadedId = prefs.getString('userId');
      
      
      if (_userId != loadedId) {
        _userId = loadedId;
        print("UserProvider - Loaded User ID: $_userId");
      }
    } catch (e) {
      print("UserProvider - Error loading user ID: $e");
      _hasError = true;
      _errorMessage = "Failed to load user data";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUserId(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', id);
      _userId = id;
      _hasError = false;
      _errorMessage = null;
      print("UserProvider - Set User ID: $_userId");
    } catch (e) {
      print("UserProvider - Error setting user ID: $e");
      _hasError = true;
      _errorMessage = "Failed to save user data";
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      
      
      _userId = null;
      _hasError = false;
      _errorMessage = null;
      
      print("UserProvider - User logged out");
    } catch (e) {
      print("UserProvider - Error during logout: $e");
      _hasError = true;
      _errorMessage = "Error during logout";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isAuthenticated() {
    return _userId != null;
  }
}
