class UPDetails {
  String name;
  String? orderCode; 
  double amount;
  String paymentMethod;
  String? paymentStatus; 
  DateTime? createdDate;
  DateTime? updatedDate;
  int pageNumber;
  int pageSize;

  UPDetails({
    required this.name,
    this.orderCode, 
    required this.amount,
    required this.paymentMethod,
    this.paymentStatus, 
    this.createdDate,
    this.updatedDate,
    required this.pageNumber,
    required this.pageSize

  });

  factory UPDetails.fromJson(Map<String, dynamic> json) => UPDetails(
    name: json["name"],
    orderCode: json["orderCode"], 
    amount: json["amount"] is int ? json["amount"].toDouble() : json["amount"].toDouble(), 
    paymentMethod: json["paymentMethod"],
    paymentStatus: json["paymentStatus"], 
    createdDate: json["createdDate"] != null ? DateTime.parse(json["createdDate"]) : null,
    updatedDate: json["updatedDate"] != null ? DateTime.parse(json["updatedDate"]) : null,
    pageNumber: json["pageNumber"],
    pageSize: json["pageSize"]
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "orderCode": orderCode, 
    "amount": amount,
    "paymentMethod": paymentMethod,
    "paymentStatus": paymentStatus, 
    "createdDate": createdDate?.toIso8601String(),
    "updatedDate": updatedDate?.toIso8601String(),
    "pageNumber": pageNumber,
    "pageSize": pageSize

  };

  @override
  String toString() {
    return 'UPDetails(name: $name, orderCode: $orderCode, amount: $amount, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus)';
  }
}