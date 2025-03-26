// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:final_canteen/model/decrease_stock_item_model.dart';
import 'package:final_canteen/model/order_item_model.dart';
import 'package:final_canteen/model/order_model.dart';
import 'package:final_canteen/page_layout/employee_dashboard.dart';
import 'package:final_canteen/providers/cart_provider.dart';
import 'package:final_canteen/providers/user_provider.dart';
import 'package:final_canteen/services/item_services.dart';
import 'package:final_canteen/services/order_service.dart';
import 'package:final_canteen/services/order_item_service.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmOrderDbox extends StatefulWidget {
  final List<dynamic> cartItems;
  final double totalAmount;
  final String? userId;

  const ConfirmOrderDbox({
    required this.cartItems,
    required this.totalAmount,
    required this.userId,
    super.key,
  });

  @override
  State<ConfirmOrderDbox> createState() => _ConfirmOrderDboxState();
}

class _ConfirmOrderDboxState extends State<ConfirmOrderDbox> {
  final OrderService _orderService = OrderService();
  final OrderItemService _orderItemService = OrderItemService();
  final ItemService _itemService = ItemService();

  final List<String> items = ["SD", "Cash"];
  String? selectedPaymentMethod;
  String? effectiveUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        effectiveUserId = widget.userId ??
            Provider.of<UserProvider>(context, listen: false).userId;
        print('Widget userId: ${widget.userId}');
        print(
            'Provider userId: ${Provider.of<UserProvider>(context, listen: false).userId}');
        print('Effective userId: $effectiveUserId');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("userId: ${widget.userId}");
    final userProvider = Provider.of<UserProvider>(context);

    if (widget.userId is Null) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Preparing Your Order",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Just a moment while we get everything ready...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (userProvider.hasError || !userProvider.isAuthenticated()) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            const Text(
              "Authentication Error",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProvider.errorMessage ??
                    "You need to be logged in to place an order.",
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              const Text(
                "Please sign in again and try once more.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text("Close"),
          ),
        ],
      );
    }

    final effectiveUserId = widget.userId ?? userProvider.userId;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_cart_checkout,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Confirm Your Order",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Method",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: selectedPaymentMethod,
                        hint: const Text(
                          "Select Payment Method",
                          style: TextStyle(fontSize: 15),
                        ),
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          color: AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        items: items.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Row(
                              children: [
                                Icon(
                                  item == "SD"
                                      ? Icons.account_balance_wallet
                                      : Icons.payments,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item == "SD"
                                      ? "Salary Deduction"
                                      : "Cash Payment",
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPaymentMethod = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                if (effectiveUserId == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade700, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'User ID not found. Please login again.',
                          style: TextStyle(
                              color: Colors.red.shade700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: effectiveUserId == null ||
                            widget.cartItems.isEmpty ||
                            selectedPaymentMethod == null
                        ? null
                        : () async {
                            final order = Order(
                              userId: effectiveUserId!,
                              totalAmount: widget.totalAmount,
                              orderDate: DateTime.now(),
                              status: "Pending",
                              paymentMethod: selectedPaymentMethod,
                            );

                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 16),
                                      const CircularProgressIndicator(),
                                      const SizedBox(height: 24),
                                      const Text(
                                        "Processing your order...",
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              );

                              final createdOrder =
                                  await _orderService.createOrder(order);

                              if (createdOrder.id != null) {
                                for (var item in widget.cartItems) {
                                  final orderItem = OrderItem(
                                    orderId: createdOrder.id!,
                                    itemId: item['itemId'],
                                    quantity: item['quantity'],
                                    price: item['price'],
                                  );

                                  await _orderItemService
                                      .createOrderItem(orderItem);
                                  await _itemService.decreaseStock(
                                      item['itemId'], item['quantity']);
                                  print(
                                      "${item['itemId']} ${item['quantity']}");
                                }

                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .clearCart();

                                Navigator.of(context).pop();

                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white),
                                        SizedBox(width: 16),
                                        Text('Order placed successfully!'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EmployeeDashboard(
                                              initialIndex: 2)),
                                );
                              } else {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Failed to place order!')),
                                );
                              }
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error: ${e.toString()}')),
                              );
                            }
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Confirm Order',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
