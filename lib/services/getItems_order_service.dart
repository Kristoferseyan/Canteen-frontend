import 'dart:convert';
import 'package:final_canteen/model/getItemsByOrder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ItemsByOrderService {
  final String baseUrl = "http://localhost:5001/api/OrderItem/order";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<List<ItemsByOrder>> fetchItemsByOrder(String orderId) async {
    String? token = await _getToken();  

    if (token == null) {
      throw Exception("No token found.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$orderId'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
    
      if (jsonResponse is List) {
        return jsonResponse.map((item) => ItemsByOrder.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to load order items. Status Code: ${response.statusCode}");
    }
  }
}
