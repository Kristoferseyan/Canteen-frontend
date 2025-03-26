
class UserPayment {
  final String id;
  final String userId;
  final String orderId;
  final double amount;
  final String paymentStatus;

  UserPayment({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.paymentStatus,
  });

  factory UserPayment.fromJson(Map<String, dynamic> json) {
    return UserPayment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      orderId: json['orderId'] as String,
      amount: (json['amount'] as num).toDouble(), 
      paymentStatus: json['paymentStatus'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'amount': amount,
      'paymentStatus': paymentStatus,
    };
  }

  static List<UserPayment> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserPayment.fromJson(json)).toList();
  }
}
