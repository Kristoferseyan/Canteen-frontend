// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:final_canteen/model/getItemsByOrder.dart';
import 'package:final_canteen/services/getItems_order_service.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';

class ViewOrderDbox extends StatefulWidget {
  final String? orderId;
  final String shortId;
  const ViewOrderDbox({
    super.key, 
    required this.orderId, 
    required this.shortId});

  @override
  State<ViewOrderDbox> createState() => _ViewOrderDboxState();
}

class _ViewOrderDboxState extends State<ViewOrderDbox> {
  final ItemsByOrderService _itemsByOrder = ItemsByOrderService();
  late Future<List<ItemsByOrder>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    
    _itemsFuture = widget.orderId != null 
      ? _itemsByOrder.fetchItemsByOrder(widget.orderId!) 
      : Future.value([]);
  }

  double _calculateTotalAmount(List<ItemsByOrder> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        height: 500,
        width: 400,
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 28,
                  color: AppColors.primary,),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Order Details for \n#${widget.shortId.substring(0, 6)}",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),),
                ),
              ],
            ),
            Divider(
              thickness: 1, 
              color: const Color.fromARGB(98, 226, 33, 19),),
            SizedBox(
              height: 400,
              width: 500,
              child: FutureBuilder<List<ItemsByOrder>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading items"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No items in this order"));
                  }

                  final items = snapshot.data!;
                  final totalAmount = _calculateTotalAmount(items);

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 9),
                              color: Colors.white,
                              elevation: 4,
                              child: ListTile(
                                title: Text(
                                  item.itemName, 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16),
                                ),

                                subtitle: Text(
                                  "x${item.quantity}", 
                                  style: TextStyle(
                                    fontSize: 13, 
                                    color: Colors.grey),),
                                trailing: Text(
                                  "₱${(item.price * item.quantity).toStringAsFixed(2)}", 
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold),), 
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(thickness: 1, color: const Color.fromARGB(98, 226, 33, 19),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Total: ₱${totalAmount.toStringAsFixed(2)}", 
                            style: TextStyle(
                              fontWeight: FontWeight.w800, 
                              fontSize: 18,
                              color: AppColors.primary),
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Close",
            style: TextStyle(color: AppColors.textWhite),),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
