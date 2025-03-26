import 'dart:convert';
import 'package:final_canteen/model/child_category_model.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  final String baseUrl = "http://localhost:5001/api/Categories";

  Future<List<Childcategory>> fetchChildCategories(String? parentCategoryName) async {
    final response = await http.get(Uri.parse('$baseUrl/children?parentName=$parentCategoryName'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final ShowChildCategory parsedResponse = ShowChildCategory.fromJson(jsonResponse);

      return parsedResponse.isSuccess ? parsedResponse.data : [];
    } else {
      throw Exception("Failed to load child categories");
    }
  }
}