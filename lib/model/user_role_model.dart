class UserRoles {
  String message;
  bool isSuccess;
  List<UserRole> data;
  int totalRecords;
  int pageNumber;
  int pageSize;

  UserRoles({
    required this.message,
    required this.isSuccess,
    required this.data,
    required this.totalRecords,
    required this.pageNumber,
    required this.pageSize,
  });

  factory UserRoles.fromJson(Map<String, dynamic> json) => UserRoles(
    message: json["message"] ?? "No message",
    isSuccess: json["isSuccess"] ?? false,
    data: json["data"] != null
      ? List<UserRole>.from(json["data"].map((x) => UserRole.fromJson(x)))
      : [],
    totalRecords: json["totalRecords"] ?? 0,
    pageNumber: json["pageNumber"] ?? 0,
    pageSize: json["pageSize"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "isSuccess": isSuccess,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "totalRecords": totalRecords,
    "pageNumber": pageNumber,
    "pageSize": pageSize,
  };
}

class UserRole {
  String id;
  String firstName;
  String lastName;
  String username;
  String password;
  String roleId;
  String roleName;

  UserRole({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.roleId,
    required this.roleName,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
    id: json["id"] ?? '',
    firstName: json["firstName"] ?? '',
    lastName: json["lastName"] ?? '',
    username: json["username"] ?? '',
    password: json["password"] ?? '',
    roleId: json["roleId"] ?? '',
    roleName: json["roleName"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "username": username,
    "password": password,
    "roleId": roleId,
    "roleName": roleName,
  };
}