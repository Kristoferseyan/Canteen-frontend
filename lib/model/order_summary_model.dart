class OrderSummaries {
  String id;
  String orderCode;
  DateTime orderDate;
  double tlAmnt;
  String status;
  String? paymentMethod;
  int pageNumber;
  int pageSize;
  

  OrderSummaries({
    required this.id,
    required this.orderCode,
    required this.orderDate,
    required this.tlAmnt,
    required this.status,
    required this.pageNumber,
    required this.pageSize,
    this.paymentMethod
  });

  factory OrderSummaries.fromJson(Map<String, dynamic> json) {
    return OrderSummaries(
    id: json["id"],
      orderCode: json["orderCode"] ?? '',
      orderDate: json["orderDate"] != null
          ? DateTime.tryParse(json["orderDate"]) ?? DateTime.now()
          : DateTime.now(),
      tlAmnt: json["tlAmnt"] ?? 0,
      status: json["status"] ?? '',
      paymentMethod: json["paymentMethod"] ?? "None",
      pageSize: json["pageSize"],
      pageNumber: json["pageNumber"]
    );
  }

  Map<String, dynamic> toJson() => {
        "orderCode": orderCode,
        "orderDate": orderDate.toIso8601String(),
        "tlAmnt": tlAmnt,
        "status": status,
        "paymentMethod": paymentMethod,
        "pageSize": pageSize,
        "pageNumber": pageNumber

      };
}
