

// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:final_canteen/model/order_model.dart';
import 'package:final_canteen/services/order_service.dart';
import 'package:final_canteen/staff_modules/widgets/completed_order_receipt.dart';
import 'package:final_canteen/staff_modules/widgets/view_order_dBox.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedOrderPages extends StatefulWidget {
  final int navbarHeight;
  const CompletedOrderPages({super.key, required this.navbarHeight});

  @override
  State<CompletedOrderPages> createState() => _CompletedOrderPagesState();
}

class _CompletedOrderPagesState extends State<CompletedOrderPages> {
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _completedOrdersFuture;
  late Future<List<Order>> _canceledOrdersFuture;

  @override
  void initState() {
    super.initState();
    _completedOrdersFuture = _orderService.fetchOrdersByStatus("Completed");
    _canceledOrdersFuture = _orderService.fetchOrdersByStatus("Cancelled");
  }

  String formatDate(DateTime? dateTime) {
    return DateFormat("yyyy-MM-dd").format(dateTime ?? DateTime.now());
  }
  String formatTime(DateTime? dateTime){
    return DateFormat("hh:mm a").format(dateTime ?? DateTime.now());
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        double availableHeight = constraints.maxHeight - widget.navbarHeight;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: availableHeight * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(Icons.check_box, color: AppColors.primary,),
                            ),
                            const Text("Completed Orders", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        const Divider(color: AppColors.primary),
                        Expanded(child: buildOrderList(_completedOrdersFuture, "Completed")),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Container(
                  width: double.infinity,
                  height: availableHeight * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(Icons.cancel, color: AppColors.primary,),
                            ),
                            const Text("Canceled Orders", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        const Divider(color: Colors.black),
                        Expanded(child: buildOrderList(_canceledOrdersFuture, "Canceled")),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

Widget buildOrderList(Future<List<Order>> ordersFuture, String title) {
  return FutureBuilder<List<Order>>(
    future: ordersFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text("Error fetching $title orders"));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text("No $title orders available"));
      }

      int crossAxisCount = MediaQuery.of(context).size.width > 800 ? 3 : 1;

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20,
          childAspectRatio: MediaQuery.of(context).size.width > 800 ? 1.6 : 1.5,
        ),
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final order = snapshot.data![index];

          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.grey.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order ID: ${order.shortId}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.shopping_cart,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 4),
                
                    buildOrderDetail(Icons.attach_money, "Total Amount", "₱${order.totalAmount}"),
                    buildOrderDetail(Icons.calendar_today, "Order Date", formatDate(order.orderDate)),
                    buildOrderDetail(Icons.punch_clock, "Order Time", formatTime(order.orderDate)),
                    buildOrderDetail(Icons.payment, "Payment", order.paymentMethod ?? "N/A"),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                ),
                                onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => CompletedOrderReceipt(orderId: order.id ?? ""),
                                );
                                },
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.visibility, size: 18),
                                  Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: Text('View Details', style: TextStyle(fontSize: 14)),
                                  ),
                                ],
                                ),
                              ),

                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget buildOrderDetail(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 27, 27, 27),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: const Color.fromARGB(255, 40, 40, 40)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

}
