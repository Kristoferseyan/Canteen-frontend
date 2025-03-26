import 'dart:convert';

// To parse this JSON data, do
//
//     final createOrUpdateUser = createOrUpdateUserFromJson(jsonString);

Roles createOrUpdateUserFromJson(String str) => Roles.fromJson(json.decode(str));

String createOrUpdateUserToJson(Roles data) => json.encode(data.toJson());

class Roles {
  String message;
  bool isSuccess;
  List<Role> data; 

  Roles({
    required this.message,
    required this.isSuccess,
    required this.data,  
  });

  factory Roles.fromJson(Map<String, dynamic> json) => Roles(
        message: json["message"],
        isSuccess: json["isSuccess"],
        data: List<Role>.from(json["data"].map((x) => Role.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "isSuccess": isSuccess,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Role {
  String? id;
  String roleName;

  Role({
    this.id,
    required this.roleName,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        roleName: json["roleName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "roleName": roleName,  
      };
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
    };
  }
}
