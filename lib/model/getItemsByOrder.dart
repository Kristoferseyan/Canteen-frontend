
class ItemsByOrder {
  final String orderId;
  final String itemId;
  final String itemName;
  final int quantity;
  final double price;

  ItemsByOrder({
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  factory ItemsByOrder.fromJson(Map<String, dynamic> json) => ItemsByOrder(
        orderId: json['orderId'] ?? '',
        itemId: json['itemId'] ?? '',
        itemName: json['itemName'] ?? 'Unknown Item',
        quantity: json['quantity'] ?? 0, 
        price: (json['price'] as num?)?.toDouble() ?? 0.0, 
      );

  Map<String, dynamic> toJson() => {
        "orderId": orderId,
        "itemId": itemId,
        "itemName": itemName,
        "quantity": quantity,
        "price": price,
      };
}
