

import 'package:final_canteen/employee_modules/pages/widgets/confirm_order_dBox.dart';
import 'package:final_canteen/providers/user_provider.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void checkoutBtn() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    showDialog(
      context: context,
      builder: (context) {
        return ConfirmOrderDbox(
          cartItems: cart.cartItems,
          totalAmount: cart.getTotalAmount(),
          userId: userId,
        );
      },
    );
  }

  void removeItemCart(String itemId) {
    Provider.of<CartProvider>(context, listen: false).removeItem(itemId);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double dialogWidth = screenWidth * 0.4;
    double dialogHeight = screenHeight * 0.8;

    bool isWideScreen = screenWidth > 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.white,
          width: dialogWidth * 0.8,
          height: dialogHeight,
          padding: const EdgeInsets.all(16),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: cart.cartItems.isEmpty
                ? const Center(child: Text('Your cart is empty', style: TextStyle(fontSize: 18, color: AppColors.primary)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: dialogWidth * 0.02,),
                          Icon(
                            Icons.shopping_basket,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: dialogWidth * 0.02,),
                          Text(
                            "Cart",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
                        ],
                      ),
                      Divider(thickness: 1, color: const Color.fromARGB(98, 226, 33, 19),),
                      Expanded(
                        child: ListView.builder(
                          itemCount: cart.cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cart.cartItems[index];
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(item['itemName'] ?? 'Unknown Item', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Quantity: ${item['quantity'] ?? 0}', style: TextStyle(color: Colors.grey)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '₱${((item['price'] ?? 0) * (item['quantity'] ?? 0)).toStringAsFixed(2)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        removeItemCart(item['itemId']);
                                      },
                                      icon: Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  checkoutBtn();
                },
                child: Text(
                  'Checkout (₱${cart.getTotalAmount()})',
                  style: TextStyle(fontSize:isWideScreen ? 18 : 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}