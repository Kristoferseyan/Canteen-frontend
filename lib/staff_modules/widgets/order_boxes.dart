import 'package:final_canteen/staff_modules/widgets/view_order_dBox.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_canteen/model/order_model.dart';

class OrderBox extends StatefulWidget {
  final String title;
  final Function(String, String, double, String?) updateOrderStatus;
  final double height;
  final String? selectedOrder;
  final Function(String) onSelectOrder;
  final Color color;
  final List<Order> orders;
  final bool isLoading;
  final VoidCallback loadMoreOrders;

  const OrderBox({
    super.key,
    required this.title,
    required this.updateOrderStatus,
    required this.height,
    required this.selectedOrder,
    required this.onSelectOrder,
    required this.color,
    required this.orders,
    required this.isLoading,
    required this.loadMoreOrders,
  });

  @override
  _OrderBoxState createState() => _OrderBoxState();
}

class _OrderBoxState extends State<OrderBox> {
  final ScrollController _scrollController = ScrollController();
  static const int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      widget.loadMoreOrders();
    }
  }

  void viewOrder(BuildContext context, String orderId, String shortId) {
    showDialog(
      context: context,
      builder: (context) {
        return ViewOrderDbox(orderId: orderId, shortId: shortId);
      },
    );
  }

  @override
  void didUpdateWidget(covariant OrderBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.orders.length > oldWidget.orders.length) {
      setState(() {}); 
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersToShow = widget.orders;

    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right:  10.0),
                  child: Icon(Icons.assignment, color: AppColors.primary,),
                ),
                Text(
                  "${widget.title} Orders",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const Divider(height: 2, indent: 12, endIndent: 12, color: AppColors.primary,),
          const SizedBox(height: 8),
          if (widget.isLoading && ordersToShow.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (ordersToShow.isEmpty)
            Expanded(child: Center(child: Text("No ${widget.title} orders available")))
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                itemCount: ordersToShow.length + (widget.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= ordersToShow.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final order = ordersToShow[index];
                  return OrderCard(
                    order: order,
                    updateOrderStatus: widget.updateOrderStatus,
                    viewOrder: viewOrder,
                    shortId: order.shortId!,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final String shortId;
  final Function(String, String, double, String?) updateOrderStatus;
  final Function(BuildContext, String, String) viewOrder;
  static final DateFormat _dateFormat = DateFormat("yyyy-MM-dd | hh:mm a");

  const OrderCard({
    super.key,
    required this.order,
    required this.updateOrderStatus,
    required this.viewOrder, 
    required this.shortId,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Order ID: ${order.shortId}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text("₱${order.totalAmount}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text("Ordered: ${_dateFormat.format(order.orderDate ?? DateTime.now())}",
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            Text("Payment: ${order.paymentMethod ?? "N/A"}",
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 10),
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDropdown(),
                      const SizedBox(height: 8),
                      _buildViewButton(context),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildDropdown()),
                      const SizedBox(width: 10),
                      _buildViewButton(context),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: order.status,
      onChanged: (newValue) {
        if (newValue != null && newValue != order.status) {
          updateOrderStatus(order.id ?? "", newValue, order.totalAmount, order.paymentMethod);
        }
      },
      items: ["Pending", "Processing", "Ready", "Completed", "Cancelled"]
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildViewButton(BuildContext context) {
    return IconButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      onPressed: () => viewOrder(context, order.id ?? "", order.shortId!),
      icon: const Icon(Icons.visibility_outlined, size: 20, color: Colors.white),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  static final Map<String, Color> _statusColors = {
    "Pending": Colors.orange,
    "Processing": Colors.blue,
    "Ready": Colors.green,
    "Completed": Colors.grey,
    "Cancelled": Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white)),
      backgroundColor: _statusColors[status] ?? Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
