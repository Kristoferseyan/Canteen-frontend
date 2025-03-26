import 'package:final_canteen/services/order_service.dart';
import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../model/order_item_model.dart';
import '../services/order_item_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final OrderItemService _orderItemService = OrderItemService();
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  
  Future<void> createOrderWithItems(String userId, List<OrderItem> cartItems) async {
    _isLoading = true;
    notifyListeners();

    try {
      double totalAmount = cartItems.fold(0, (sum, item) => sum + ((item.price) * item.quantity).toDouble());
      Order newOrder = Order(
        userId: userId,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        status: "Pending", 
      );

      Order? createdOrder = await _orderService.createOrder(newOrder);

      for (var item in cartItems) {
        OrderItem newItem = OrderItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          orderId: createdOrder.id!, 
          itemId: item.itemId,
          quantity: item.quantity,
          price: item.price,
        );
        await _orderItemService.createOrderItem(newItem);
      }

      _orders.add(createdOrder);
      notifyListeners();
    } catch (e) {
      print("Error creating order: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  
  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _orderService.fetchOrders();
      notifyListeners();
    } catch (e) {
      print("Error fetching orders: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  
  Future<void> updateOrderStatus(String orderId, String newStatus, double tlAmnt, String paymentMethod) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus, tlAmnt, paymentMethod);
      _orders = _orders.map((order) {
        if (order.id == orderId) {
          return Order(
            id: order.id,
            userId: order.userId,
            totalAmount: order.totalAmount,
            orderDate: order.orderDate,
            status: newStatus, 
          );
        }
        return order;
      }).toList();
      notifyListeners();
    } catch (e) {
      print("Error updating order status: $e");
    }
  }
}