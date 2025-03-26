// To parse this JSON data, do
//
//     final showChildCategory = showChildCategoryFromJson(jsonString);

import 'dart:convert';

ShowChildCategory showChildCategoryFromJson(String str) => ShowChildCategory.fromJson(json.decode(str));

String showChildCategoryToJson(ShowChildCategory data) => json.encode(data.toJson());

class ShowChildCategory {
    String message;
    bool isSuccess;
    List<Childcategory> data;

    ShowChildCategory({
        required this.message,
        required this.isSuccess,
        required this.data,
    });

    factory ShowChildCategory.fromJson(Map<String, dynamic> json) => ShowChildCategory(
        message: json["message"],
        isSuccess: json["isSuccess"],
        data: List<Childcategory>.from(json["data"].map((x) => Childcategory.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "isSuccess": isSuccess,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Childcategory {
    String? id;
    String categoryName;
    String? parentCategoryId;

    Childcategory({
        this.id,
        required this.categoryName,
        this.parentCategoryId,
    });

    factory Childcategory.fromJson(Map<String, dynamic> json) => Childcategory(
        id: json["id"],
        categoryName: json["categoryName"],
        parentCategoryId: json["parentCategoryId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "categoryName": categoryName,
        "parentCategoryId": parentCategoryId,
    };
}
