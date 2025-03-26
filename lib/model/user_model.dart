// To parse this JSON data, do
//
//     final createOrUpdateUser = createOrUpdateUserFromJson(jsonString);

import 'dart:convert';

CreateOrUpdateUser createOrUpdateUserFromJson(String str) =>
    CreateOrUpdateUser.fromJson(json.decode(str));

String createOrUpdateUserToJson(CreateOrUpdateUser data) =>
    json.encode(data.toJson());

class CreateOrUpdateUser {
  String message;
  bool isSuccess;
  User data;

  CreateOrUpdateUser({
    required this.message,
    required this.isSuccess,
    required this.data,
  });

  factory CreateOrUpdateUser.fromJson(Map<String, dynamic> json) =>
      CreateOrUpdateUser(
        message: json["message"],
        isSuccess: json["isSuccess"],
        data: User.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "isSuccess": isSuccess,
        "data": data.toJson(),
      };
}

class User {
  String? id;
  String? firstName;
  String? lastName;
  String? username;
  String? password;
  String? roleId;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        username: json["username"],
        password: json["password"],
        roleId: json["roleId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "username": username,
        "password": password,
        "roleId": roleId,
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
