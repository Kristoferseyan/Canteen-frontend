import 'dart:convert';
import 'package:final_canteen/model/parent_category_model.dart';
import 'package:http/http.dart' as http;

class ParentCategoryApiServices {
  final String apiUrl = 'http://localhost:5001/api/MenuItem/parent-categories';

  Future<List<ShowParentCategory>> fetchParentCategories() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
          .map((item) => ShowParentCategory.fromJson(item))
          .where((category) => category.categoryName != 'Deleted Items')
          .toList();
      } else {
        throw Exception('Failed to load parent categories');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }
}
