// To parse this JSON data, do
//
//     final receipts = receiptsFromJson(jsonString);

import 'dart:convert';

Receipts receiptsFromJson(String str) => Receipts.fromJson(json.decode(str));

String receiptsToJson(Receipts data) => json.encode(data.toJson());

class Receipts {
  String message;
  bool isSuccess;
  Receipt data;
  int totalRecords;
  int pageNumber;
  int pageSize;

  Receipts({
    required this.message,
    required this.isSuccess,
    required this.data,
    required this.totalRecords,
    required this.pageNumber,
    required this.pageSize,
  });

  factory Receipts.fromJson(Map<String, dynamic> json) => Receipts(
        message: json["message"],
        isSuccess: json["isSuccess"],
        data: Receipt.fromJson(json["data"]),
        totalRecords: json["totalRecords"],
        pageNumber: json["pageNumber"],
        pageSize: json["pageSize"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "isSuccess": isSuccess,
        "data": data.toJson(),
        "totalRecords": totalRecords,
        "pageNumber": pageNumber,
        "pageSize": pageSize,
      };
}

class Receipt {
  String id;
  String receiptNumber;
  String orderId;
  String paymentId;
  DateTime issuedDate;
  double totalAmount;
  bool voided;
  String? voidReason;

  Receipt({
    required this.id,
    required this.receiptNumber,
    required this.orderId,
    required this.paymentId,
    required this.issuedDate,
    required this.totalAmount,
    required this.voided,
    required this.voidReason,
  });

  double get amount => totalAmount / 100.0;

  factory Receipt.fromJson(Map<String, dynamic> json) {
    try {
      return Receipt(
        id: json['id']?.toString() ?? '',
        receiptNumber: json['receiptNumber']?.toString() ?? '',
        orderId: json['orderId']?.toString() ?? '',
        paymentId: json['paymentId']?.toString() ?? '',
        issuedDate: json['issuedDate'] != null 
            ? DateTime.parse(json['issuedDate'].toString()) 
            : DateTime.now(),
        totalAmount: json['totalAmount'] ?? 0.00,
        voided: json['voided'] ?? false,
        voidReason: json['voidReason']?.toString(),
      );
    } catch (e) {
      print("Error parsing receipt JSON: $e");
      print("Problematic JSON: $json");
      rethrow;
    }
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "receiptNumber": receiptNumber,
        "orderId": orderId,
        "paymentId": paymentId,
        "issuedDate": issuedDate.toIso8601String(),
        "totalAmount": totalAmount,
        "voided": voided,
        "voidReason": voidReason,
      };
}
