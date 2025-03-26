import 'package:final_canteen/services/item_services.dart';
import 'package:final_canteen/staff_modules/widgets/featured_toggle_btn.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:final_canteen/model/menu_item_model.dart';

class AddstockItemCard extends StatefulWidget {
  final String itemName;
  final int stock;
  final String id;
  final String description;
  final double price;
  final String categoryId;
  final DateTime? featuredStartTime;
  final DateTime? featuredEndTime;
  final Function() onStockUpdated;
  final Function(bool)? onFeaturedToggled;

  const AddstockItemCard({
    Key? key,
    required this.itemName,
    required this.stock,
    required this.id,
    required this.description,
    required this.price,
    required this.categoryId,
    this.featuredStartTime,
    this.featuredEndTime,
    required this.onStockUpdated,
    this.onFeaturedToggled,
  }) : super(key: key);

  @override
  State<AddstockItemCard> createState() => _AddstockItemCardState();
}

class _AddstockItemCardState extends State<AddstockItemCard> {
  final ItemService _itemService = ItemService();
  late int availableStock;

  // Create an item object to use with the FeaturedToggleButton
  ItemByCategory get _item => ItemByCategory(
    id: widget.id,
    itemName: widget.itemName,
    description: widget.description,
    price: widget.price,
    categoryId: widget.categoryId,
    stock: widget.stock,
    featuredStartTime: widget.featuredStartTime,
    featuredEndTime: widget.featuredEndTime,
  );

  @override
  void initState() {
    super.initState();
    availableStock = widget.stock;
  }

  @override
  void didUpdateWidget(covariant AddstockItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stock != widget.stock) {
      setState(() {
        availableStock = widget.stock;
      });
    }
  }

  void increment() {
    setState(() {
      availableStock++;
    });
  }

  void decrement() {
    if (availableStock > 0) {
      setState(() {
        availableStock--;
      });
    }
  }

  void checkValues() {
    print('Checked Values - '
        '${widget.id},'
        '${widget.itemName},'
        '${widget.description},'
        '${widget.price},'
        '${widget.categoryId},'
        '$availableStock');
  }

  Future<void> updateStock() async {
    try {
      await _itemService.updateStock(
        widget.id,
        widget.itemName,
        widget.description,
        widget.price,
        widget.categoryId,
        availableStock,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stock updated successfully!")),
      );

      widget.onStockUpdated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update stock: $e")),
      );
    }
  }

  Future<void> deleteStock() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Confirm Deletion",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this item?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _itemService.deleteMenuItem(widget.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully!")),
        );
        widget.onStockUpdated();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete item: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;

    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding:
            isMobile ? const EdgeInsets.all(8.0) : const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    widget.itemName,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: deleteStock,
                  icon: const Icon(Icons.delete, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: decrement,
                  icon: const Icon(Icons.remove_circle_outline, size: 28),
                  color: AppColors.primary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    availableStock.toString(),
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: increment,
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                checkValues();
                updateStock();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: isMobile
                    ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                    : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Update Stock",
                style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            FeaturedToggleButton(
              item: _item,
              onToggle: (isFeatured) {
                if (widget.onFeaturedToggled != null) {
                  widget.onFeaturedToggled!(isFeatured);
                }
              },
            ),
            if (_item.isFeatured)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      _item.featuredTimeRemaining,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
