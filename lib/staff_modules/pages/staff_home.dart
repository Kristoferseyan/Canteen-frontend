import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:final_canteen/services/order_service.dart';
import 'package:final_canteen/model/order_model.dart';
import 'package:final_canteen/staff_modules/widgets/order_boxes.dart';

class StaffHome extends StatefulWidget {
  final double navbarHeight;
  const StaffHome({super.key, required this.navbarHeight});

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  final OrderService _orderService = OrderService();
  String? selectedOrderId;

  final Map<String, List<Order>> _orders = {
    "Pending": [],
    "Processing": [],
    "Ready": []
  };

  final Map<String, bool> _isLoadingMore = {
    "Pending": false,
    "Processing": false,
    "Ready": false
  };

  final Map<String, int> _pageNumbers = {
    "Pending": 1,
    "Processing": 1,
    "Ready": 1
  };

  final int pageSize = 10;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialOrders();
  }

  Future<void> _loadInitialOrders() async {
    await Future.wait(["Pending", "Processing", "Ready"].map(_fetchOrders));
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchOrders(String status) async {
    try {
      final newOrders = await _orderService.fetchOrdersByStatus(status, 
        pageNumber: _pageNumbers[status]!, pageSize: pageSize);
      if (mounted) {
        setState(() => _orders[status] = newOrders);
      }
    } catch (e) {
      print("Error fetching $status orders: $e");
    }
  }

  Future<void> _loadMoreOrders(String status) async {
    if (_isLoadingMore[status]!) return;

    setState(() => _isLoadingMore[status] = true);
    _pageNumbers[status] = _pageNumbers[status]! + 1;

    try {
      final moreOrders = await _orderService.fetchOrdersByStatus(status, 
        pageNumber: _pageNumbers[status]!, pageSize: pageSize);
      
      if (mounted) {
        setState(() {
          _orders[status]!.addAll(moreOrders);
          _isLoadingMore[status] = false;
        });
      }
    } catch (e) {
      print("Error loading more $status orders: $e");
      setState(() => _isLoadingMore[status] = false);
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus, double totalAmount, String? paymentMethod) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus, totalAmount, paymentMethod ?? "");
      
      
      setState(() {
        _orders.forEach((status, orders) {
          orders.removeWhere((order) => order.id == orderId);
        });
        _fetchOrders(newStatus); 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    } catch (e) {
      print("Error updating order status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status')),
      );
    }
  }

  void _selectOrder(String orderId) {
    setState(() => selectedOrderId = orderId);
  }

@override
Widget build(BuildContext context) {
  print('$selectedOrderId');
  return Scaffold(
    backgroundColor: Colors.white,
    body: LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 700;
        double availableHeight = constraints.maxHeight - widget.navbarHeight;

        List<Widget> orderBoxes = ["Pending", "Processing", "Ready"].map((status) {
          return SizedBox(
            height: isDesktop ? availableHeight : availableHeight / 2.5,
            child: OrderBox(
              
              height: availableHeight,
              color: _getOrderBoxColor(status),
              title: status,
              orders: _orders[status]!,
              isLoading: isLoading,
              updateOrderStatus: _updateOrderStatus,
              selectedOrder: selectedOrderId,
              onSelectOrder: _selectOrder,
              loadMoreOrders: () => _loadMoreOrders(status),
            ),
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: orderBoxes[0]), 
                    const SizedBox(width: 15),
                    Flexible(child: orderBoxes[1]),
                    const SizedBox(width: 15),
                    Flexible(child: orderBoxes[2]),
                  ],
                )
              : SingleChildScrollView( 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      orderBoxes[0],
                      const SizedBox(height: 15),
                      orderBoxes[1],
                      const SizedBox(height: 15),
                      orderBoxes[2],
                    ],
                  ),
                ),
        );
      },
    ),
  );
}


  Color _getOrderBoxColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.amber.shade100;
      case "Processing":
        return Colors.green.shade100;
      case "Ready":
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
