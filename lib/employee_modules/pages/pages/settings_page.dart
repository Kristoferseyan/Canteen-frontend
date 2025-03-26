import 'package:final_canteen/providers/user_provider.dart';
import 'package:final_canteen/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  Future<void> logout() async {
    setState(() {
      _isLoggingOut = true;
    });
    try {
      await Provider.of<UserProvider>(context, listen: false).logout();
      final success = await _authService.logout(context);
      
      if (!success && mounted) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.'))
        );
        setState(() {
          _isLoggingOut = false;
        });
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'))
        );
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _isLoggingOut ? null : logout,
        child: _isLoggingOut 
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(strokeWidth: 2)
            )
          : const Text("Log out")
      ),
    );
  }
}