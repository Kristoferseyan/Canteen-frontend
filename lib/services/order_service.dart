import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/order_model.dart';
import '../services/receipt_service.dart';
import '../services/user_payment_service.dart';

class OrderService {
  final String baseUrl = "http://localhost:5001/api";
  final ReceiptService _receiptService = ReceiptService();
  final UserPaymentService _userPaymentService = UserPaymentService();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<Order> createOrder(Order order) async {
    String? token = await _getToken();

    if (token == null) {
      throw Exception("No token found.");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/Order/createOrUpdate'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create order');
    }
  }

  Future<List<Order>> fetchOrders(
      {int pageNumber = 1, int pageSize = 20}) async {
    String? token = await _getToken();

    if (token == null) {
      throw Exception("No token found.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/Order/all?pageNumber=$pageNumber&pageSize=$pageSize'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return jsonResponse.map((item) => Order.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<List<Order>> fetchOrdersByStatus(String orderStatus,
      {int pageNumber = 1, int pageSize = 20}) async {
    String? token = await _getToken();

    if (token == null) {
      throw Exception("No token found.");
    }

    final response = await http.get(
      Uri.parse(
          '$baseUrl/Order/byStatus?status=$orderStatus&pageNumber=$pageNumber&pageSize=$pageSize'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey("orders")) {
        final List<dynamic> orderList = jsonResponse["orders"];
        return orderList.map((item) => Order.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load orders: ${response.body}');
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus,
      double totalAmount, String paymentMethod) async {
    try {
      String? token = await _getToken();

      if (token == null) {
        throw Exception("No token found.");
      }

      final response = await http.post(
        Uri.parse('$baseUrl/Order/createOrUpdate'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "id": orderId,
          "status": newStatus,
          "orderDate": DateTime.now().toIso8601String(),
          "tlAmnt": totalAmount,
          "userId": "00000000-0000-0000-0000-000000000000",
          "paymentMethod": paymentMethod
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update order status');
      }
      if (newStatus.toLowerCase() == "completed") {
        try {
          final order = await fetchOrderById(orderId);

          final existingReceipt =
              await _receiptService.getReceiptByOrderId(orderId);
          if (existingReceipt != null) {
            return true;
          }

          final payment =
              await _userPaymentService.getPaymentByOrderId(orderId);

          String paymentId = payment['id'];

          final receipt = await _receiptService.createReceiptWithPaymentId(
              order, paymentId);

          if (receipt != null) {
          } else {}

          return true;
        } catch (receiptError) {
          print("Error generating receipt: $receiptError");
          return true;
        }
      }

      return true;
    } catch (e) {
      print("Error updating order status: $e");
      return false;
    }
  }

  Future<bool> generateReceiptForCompletedOrder(String orderId) async {
    try {
      print("Manually generating receipt for order: $orderId");

      final order = await fetchOrderById(orderId);
      print("Found order: ${order.id}, status: ${order.status}");

      if (order.status.toLowerCase() != "completed") {
        print(
            "Cannot generate receipt for non-completed order. Status: ${order.status}");
        return false;
      }
      final existingReceipt =
          await _receiptService.getReceiptByOrderId(orderId);
      if (existingReceipt != null) {
        print("Receipt already exists for order: $orderId");
        return true;
      }

      final payment = await _userPaymentService.getPaymentByOrderId(orderId);

      String paymentId;
      paymentId = payment['id'];

      final receipt =
          await _receiptService.createReceiptWithPaymentId(order, paymentId);

      if (receipt != null) {
        return true;
      } else {
        print("Failed to create receipt");
        return false;
      }
    } catch (e) {
      print("Error generating receipt: $e");
      return false;
    }
  }

  Future<Order> fetchOrderById(String orderId) async {
    String? token = await _getToken();

    if (token == null) {
      throw Exception("No token found.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/Order/$orderId'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey("data")) {
        return Order.fromJson(jsonResponse["data"]);
      } else {
        throw Exception('Invalid response format for order details');
      }
    } else {
      throw Exception('Failed to fetch order details: ${response.statusCode}');
    }
  }

  Future<List<Order>> fetchCompletedOrdesByUserId(String userId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/Order/by-userId?userId=$userId"));

    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse.containsKey("data")) {
      final List<dynamic> ordersList = jsonResponse["data"];
      return ordersList.map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('Invalid response format for order details');
    }
  }
}
