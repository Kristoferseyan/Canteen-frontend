class Order {
  final String? id; 
  final String userId;
  final double totalAmount;
  final DateTime? orderDate;
  final String status;
  final String? shortId;
  final String? paymentMethod;
  final int pageNumber;
  final int pageSize;
  final int totalRecords;

  Order({
    this.id, 
    required this.userId,
    required this.totalAmount,
    this.orderDate,
    required this.status, 
    this.shortId,
    this.paymentMethod,
    this.pageNumber = 1, 
    this.pageSize = 20, 
    this.totalRecords = 0,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'], 
      userId: json['userId'],
      totalAmount: (json['tlAmnt'] as num).toDouble(),
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : null,
      status: json['status'] ?? 'Pending', 
      shortId: json['shortId'] ?? 'None',
      paymentMethod: json['paymentMethod'] ?? 'None',
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'userId': userId,
      'tlAmnt': totalAmount,
      'orderDate': orderDate?.toIso8601String(),
      'status': status, 
      'shortId': shortId,
      'paymentMethod' : paymentMethod,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalRecords': totalRecords,
    };
  }

  @override
  String toString() {
    return 'Order(id: $id, shortId: $shortId, userId: $userId, totalAmount: $totalAmount, orderDate: $orderDate, status: $status, paymentMethod: $paymentMethod, pageNumber: $pageNumber, pageSize: $pageSize, totalRecords: $totalRecords)';
  }
}
