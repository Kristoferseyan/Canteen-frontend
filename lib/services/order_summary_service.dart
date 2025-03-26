import 'package:final_canteen/model/order_summary_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderSummaryService {
  final String baseUrl = "http://localhost:5001/api/Order/summaries";
  
  Future<List<OrderSummaries>> fetchOrderSummary(String userId, String orderStatus, int pageNumber, int pageSize) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) {
      throw Exception('No JWT token found, please log in first');
    }
    
    final url = "$baseUrl?userId=$userId&orderStatus=$orderStatus&pagenumber=$pageNumber&pageSize=$pageSize";
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse["isSuccess"] == true && jsonResponse["data"] != null) {
          return List<OrderSummaries>.from(
            jsonResponse["data"].map((x) => OrderSummaries.fromJson(x))
          );
        } else {
          print("No $orderStatus orders found for user $userId");
          return [];
        }
      } else {
        print('Failed to load $orderStatus orders: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching $orderStatus orders: $e');
      return [];
    }
  }
}