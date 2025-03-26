import 'dart:convert';

import 'package:final_canteen/model/UnpaidSDBalance.dart';
import 'package:final_canteen/model/userPayment_details_model.dart';
import 'package:final_canteen/model/user_payment_model.dart';
import 'package:http/http.dart' as http;

class UserPaymentService {
  final String baseUrl = "http://localhost:5001/api/UserPayments";

  Future<List<UserPayment>> fetchPaymentsByUserId(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: {
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse is List) {
        return jsonResponse.map((item) => UserPayment.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception(
          "Failed to load order paymentds. Status Code: ${response.statusCode}");
    }
  }

  Future<List<UPDetails>> fetchUPDetails({
    String? paymentMethod,
    String? paymentStatus,
    String? name,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      String url = '$baseUrl/RetrievePayments';
      Map<String, String> queryParams = {};

      queryParams['pageNumber'] = pageNumber.toString();
      queryParams['pageSize'] = pageSize.toString();

      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        queryParams['paymentMethod'] = paymentMethod;
      }
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams['paymentStatus'] = paymentStatus;
      }
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }

      if (queryParams.isNotEmpty) {
        url += '?' + Uri(queryParameters: queryParams).query;
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load details: ${response.statusCode}');
      }

      final decodedData = json.decode(response.body);

      if (!decodedData['isSuccess']) {
        throw Exception('Error: ${decodedData['message']}');
      }

      final List<dynamic> usersJson =
          decodedData['data'] != null && decodedData['data'] is List
              ? List<dynamic>.from(decodedData['data'])
              : [];

      usersJson.sort((a, b) {
        final aDate = a['updatedDate'];
        final bDate = b['updatedDate'];

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        try {
          return DateTime.parse(bDate).compareTo(DateTime.parse(aDate));
        } catch (e) {
          return 0;
        }
      });

      return usersJson.map((json) => UPDetails.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching user payment details: $e');
    }
  }

  Future<List<UPDetails>> fetchUPDetailsByName(String name) async {
    final response = await http.get(
      Uri.parse('$baseUrl/RetrievePaymentsByName/$name'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] is List) {
        return (jsonResponse['data'] as List)
            .map((json) => UPDetails.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception(
          "Failed to load payment details. Status Code: ${response.statusCode}");
    }
  }

  Future<double> fetchUnpaidSDBalance(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/balance/$userId'),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch unpaid SD balance. Status code: ${response.statusCode}');
      }

      if (response.body.isEmpty) {
        throw Exception('Empty response received');
      }

      final decodedData = json.decode(response.body);

      if (decodedData['isSuccess'] == true) {
        final dynamic balanceData = decodedData['data'];
        if (balanceData is int) {
          return balanceData.toDouble();
        } else if (balanceData is double) {
          return balanceData;
        } else if (balanceData is String) {
          return double.tryParse(balanceData) ?? 0.0;
        }

        return 0.0;
      } else {
        throw Exception(
            decodedData['message'] ?? 'Failed to retrieve unpaid SD balance');
      }
    } catch (e) {
      print('Error fetching unpaid SD balance: $e');
      return 0.0; // Return 0 as a fallback in case of errors
    }
  }

  Future<UnpaidSDBalanceResponse> getUnpaidSDBalanceByName(String name) async {
    final encodedName = Uri.encodeComponent(name);
    final url = Uri.parse('$baseUrl/balanceByName/$encodedName');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer <your_token>',
    });
    if (response.statusCode == 200) {
      return UnpaidSDBalanceResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load unpaid SD balance');
    }
  }

  Future<dynamic> getPaymentByOrderId(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/by-order/$orderId'),
        headers: {
          "Accept": "application/json",
        },
      );
      
      print("Get payment response: ${response.statusCode}, ${response.body}");
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['isSuccess'] == true && jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        return null;
      } else {
        print("Failed to get payment: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception in getPaymentByOrderId: $e");
      return null;
    }
  }
}
