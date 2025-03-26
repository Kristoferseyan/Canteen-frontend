import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/order_item_model.dart';

class OrderItemService {
  final String baseUrl = "http://localhost:5001/api/OrderItem"; 
Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("jwt_token");
}

Future<OrderItem?> createOrderItem(OrderItem orderItem) async {
  try {
    String? token = await _getToken(); 
    if (token == null) {
      throw Exception("No token found.");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/createOrUpdate"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", 
      },
      body: jsonEncode(orderItem.toJson()),
    );

    print("Response status: ${response.statusCode}");
    print("API Response: ${response.body}");

    final responseData = jsonDecode(response.body);

    print("Decoded data: $responseData");

    if (response.statusCode == 200 && responseData['isSuccess'] == true) {
      print("Parsed OrderItem Data: ${responseData['data']}");
      return OrderItem.fromJson(responseData['data']);
    } else {
      print("Error creating order item: ${response.body}");
      throw Exception("Failed to create or update order item");
    }
  } catch (e) {
    print("Error: $e");
    throw Exception("Failed to create order item");
  }
}

Future<List<OrderItem>> fetchOrderItems(String orderId) async {
  try {
    String? token = await _getToken();
    if (token == null) {
      throw Exception("No token found.");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/$orderId"),
      headers: {
        "Authorization": "Bearer $token", 
      },
    );

    print("Fetch Order Items Response status: ${response.statusCode}");
    print("Fetch Order Items API Response: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print("Parsed Order Items Data: $data");
      return data.map((item) => OrderItem.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load order items");
    }
  } catch (e) {
    print("Error: $e");
    throw Exception("Failed to fetch order items");
  }
}
}
