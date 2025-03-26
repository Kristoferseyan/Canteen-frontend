// To parse this JSON data, do
//
//     final showParentCategory = showParentCategoryFromJson(jsonString);

import 'dart:convert';

List<ShowParentCategory> showParentCategoryFromJson(String str) => List<ShowParentCategory>.from(json.decode(str).map((x) => ShowParentCategory.fromJson(x)));

String showParentCategoryToJson(List<ShowParentCategory> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class  ShowParentCategory {
    String? id;
    String categoryName;
    dynamic parentCategoryId;

    ShowParentCategory({
        this.id,
        required this.categoryName,
        required this.parentCategoryId,
    });

    factory ShowParentCategory.fromJson(Map<String, dynamic> json) => ShowParentCategory(
        id: json["id"],
        categoryName: json["categoryName"],
        parentCategoryId: json["parentCategoryId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "categoryName": categoryName,
        "parentCategoryId": parentCategoryId,
    };
    @override
    String toString() {
      return 'ShowParentCategory(id: $id, categoryName: $categoryName, parentCategoryId: $parentCategoryId)';
  }
}
