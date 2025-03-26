class OrderItem {
  final String? id; 
  final String orderId; 
  final String itemId;
  final int quantity;
  final double price;

  OrderItem({
    this.id,  
    required this.orderId, 
    required this.itemId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'], 
      itemId: json['itemId'],
      quantity: json['quantity'],
      price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'orderId': orderId,
      'itemId': itemId,
      'quantity': quantity,
      'price': price,
    };
  }
}
