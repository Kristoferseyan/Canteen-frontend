
class DecreaseStocks {
  String id;
  String? itemName;
  String? description;
  double? price;
  String? categoryId;
  int stock;

  DecreaseStocks({
    required this.id,
    this.itemName,
    this.description,
    this.price,
    this.categoryId,
    required this.stock,
  });

  factory DecreaseStocks.fromJson(Map<String, dynamic> json) => DecreaseStocks(
    id: json["id"],
    itemName: json["itemName"],
    description: json["description"],
    price: json["price"].toDouble(),
    categoryId: json["categoryId"],
    stock: json["stock"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "itemName": itemName,
    "description": description,
    "price": price,
    "categoryId": categoryId,
    "stock": stock,
  };
}