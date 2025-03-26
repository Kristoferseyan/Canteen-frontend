// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:final_canteen/admin-modules/widget/removed_itemCard.dart';
import 'package:final_canteen/model/menu_item_model.dart';
import 'package:final_canteen/model/order_model.dart';
import 'package:final_canteen/services/child_category_services.dart';
import 'package:final_canteen/services/item_services.dart';
import 'package:final_canteen/staff_modules/widgets/addStock_item_card.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RemovedItemsPage extends StatefulWidget {
  final double navbarHeight;
  const RemovedItemsPage({super.key, required this.navbarHeight});

  @override
  State<RemovedItemsPage> createState() => _RemovedItemsPageState();
}

class _RemovedItemsPageState extends State<RemovedItemsPage> {
  final ItemService _itemService = ItemService();
  final CategoryService _childCategoryService = CategoryService();

  List<ItemByCategory> items = [];

  String categoryId = 'E05D3437-4B6C-482D-9B60-6C22B17ABF60';

  @override
  void initState() {
    super.initState();
    fetchMenuItemsByParentCategory();
  }

  Future<void> fetchMenuItemsByParentCategory() async {
    List<ItemByCategory> allItems = await _itemService.fetchMenuItemsByParentCategory(categoryId);
    if (mounted) {
      setState(() {
        items = allItems;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildStockGrid(),
    );
  }

  Widget _buildStockGrid() {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 700;
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 600;
        double availableHeight = constraints.maxHeight - widget.navbarHeight;

        return Container(
          height: availableHeight,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.inventory_rounded, color: AppColors.primary, size: isDesktop ? 40 : 30,),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Removed Items",
                      style: TextStyle(
                        fontSize: isDesktop ? 30 : 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text("No items found."))
                    : GridView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 2 : 1,
                          childAspectRatio: isDesktop ? 2 : 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return RemovedItemCard(
                            itemName: item.itemName, 
                            stock: item.stock, 
                            description: item.description, 
                            price: item.price,);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}