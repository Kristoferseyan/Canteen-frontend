import 'dart:convert';
import 'package:final_canteen/model/decrease_stock_item_model.dart';
import 'package:final_canteen/model/menu_item_model.dart';
import 'package:http/http.dart' as http;

class ItemService {
  final String baseUrl = "http://localhost:5001/api/MenuItem";

  Future<List<ItemByCategory>> fetchFeaturedItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/featured'));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load featured items: ${response.statusCode}');
      }
      
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      
      if (jsonResponse['isSuccess'] == true && jsonResponse.containsKey('data')) {
        final List<dynamic> itemsData = jsonResponse['data'];
        return itemsData
            .map((item) => ItemByCategory.fromJson(item))
            .toList();
      } else {
        print('No featured items found: ${jsonResponse['message']}');
        return [];
      }
    } catch (e) {
      print('Error fetching featured items: $e');
      return [];
    }
  }

  Future<bool> setItemAsFeatured(String itemId, DateTime startTime, DateTime endTime) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$itemId/set-featured'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'menuItemId': itemId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['isSuccess'] == true;
      } else {
        print('Failed to set item as featured: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception setting item as featured: $e');
      return false;
    }
  }

  Future<bool> removeFeaturedStatus(String itemId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/remove-featured'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'menuItemId': itemId
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['isSuccess'] == true;
      } else {
        print('Failed to remove featured status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception removing featured status: $e');
      return false;
    }
  }

  Future<List<ItemByCategory>> fetchMenuItemsByCategory(String categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/GetByCategory/$categoryId'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse["isSuccess"]) {
        return (jsonResponse["data"] as List)
            .map((item) => ItemByCategory.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to load menu items");
    }
  }

  Future<List<ItemByCategory>> fetchMenuItemsByParentCategory(String categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/by-parent-category/$categoryId'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse["isSuccess"]) {
        return (jsonResponse["data"] as List)
            .map((item) => ItemByCategory.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to load menu items");
    }
  }

  Future<ItemByCategory> updateStock(String id, String itemName, String description, double price, String categoryId, int stock) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "id": id,
        "itemName": itemName,
        "description": description,
        "price": price,
        "categoryId": categoryId,
        "stock": stock
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ItemByCategory.fromJson(data);
    } else {
      throw Exception('Failed to update stock: ${response.body}');
    }
  }

  Future<ItemByCategory> addStock(String itemName, String description, double price, String categoryId, int stock) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "itemName": itemName,
        "description": description,
        "price": price,
        "categoryId": categoryId,
        "stock": stock
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ItemByCategory.fromJson(data);
    } else {
      throw Exception('Failed to add stock: ${response.body}');
    }
  }

  Future<bool> deleteMenuItem(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse["isSuccess"];
    } else {
      throw Exception('Failed to delete menu item: ${response.body}');
    }
  }

  Future<DecreaseStocks> decreaseStock(String itemId, int stock) async {
    final url = Uri.parse('$baseUrl/decrease-stock');

    final requestBody = json.encode({
      'id': itemId,   
      'stock': stock,  
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return DecreaseStocks.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to decrease stock: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Error: $error');
    }
  }
}