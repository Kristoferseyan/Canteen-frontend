import 'dart:convert';
import 'package:final_canteen/model/order_model.dart';
import 'package:final_canteen/model/receipt_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptService {
  final String baseUrl = "http://localhost:5001/api/Receipt";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<Receipt?> createReceiptWithPaymentId(Order order, String paymentId) async {
    try {
      String? token = await _getToken();
    
      String validPaymentId;
      validPaymentId = paymentId;
      
      final Map<String, dynamic> receiptData = {
        "receiptNumber": "RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}",
        "orderId": order.id,
        "paymentId": validPaymentId,
        "issuedDate": DateTime.now().toIso8601String(),
        "totalAmount": (order.totalAmount * 100).round(), 
        "voided": false,
        "voidReason": null 
      };
      
      print("Creating receipt with data: ${jsonEncode(receiptData)}");
      
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };
      
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/CreateReceipt'),
        headers: headers,
        body: jsonEncode(receiptData)
      );
      
      print("Receipt API response code: ${response.statusCode}");
      print("Receipt API response body: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['isSuccess'] == true && jsonResponse.containsKey('data')) {
          return Receipt.fromJson(jsonResponse['data']);
        } else {
          print("API returned success=false: ${jsonResponse['message']}");
          return null;
        }
      } else {
        print("API error: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in createReceiptWithPaymentId: $e");
      return null;
    }
  }


  Future<Receipt?> getReceiptByOrderId(String orderId) async {
    try {
      String? token = await _getToken();
      
      Map<String, String> headers = {
        "Accept": "application/json"
      };
      
      final response = await http.get(
        Uri.parse('$baseUrl/GetReceipt-byOrderId?orderId=$orderId'),
        headers: headers
      );
      
      print("Get receipt response: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['isSuccess'] == true && jsonResponse.containsKey('data')) {
          return Receipt.fromJson(jsonResponse['data']);
        } 
        return null;
      } else if (response.statusCode == 404) {
        print("Receipt not found for order: $orderId");
        print(response.body);
        return null;
      } else {
        print("Error fetching receipt: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in getReceiptByOrderId: $e");
      return null;
    }
  }
}