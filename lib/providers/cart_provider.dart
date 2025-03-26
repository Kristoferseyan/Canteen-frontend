import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addItem(String itemId, String itemName, int quantity, double price) {
    int index = _cartItems.indexWhere((item) => item['itemId'] == itemId);

    if (index != -1) {
      _cartItems[index]['quantity'] += quantity;
    } else {
      _cartItems.add({
        "itemId": itemId,
        "itemName": itemName,
        "quantity": quantity,
        "price": price,
      });
    }

    notifyListeners();
  }

  void removeItem(String itemId) {
    _cartItems.removeWhere((item) => item['itemId'] == itemId);
    notifyListeners();
  }

  void dStock(String itemId, int quantity) {
    int index = _cartItems.indexWhere((item) => item['itemId'] == itemId);
    if (index != -1) {
      _cartItems[index]['quantity'] = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

double getTotalAmount() {
  return _cartItems.fold(0, (sum, item) => 
    sum + (double.parse(item['price'].toString()) * double.parse(item['quantity'].toString())).toDouble()
  );
}

}
