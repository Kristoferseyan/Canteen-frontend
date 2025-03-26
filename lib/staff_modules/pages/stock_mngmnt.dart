

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:final_canteen/model/child_category_model.dart';
import 'package:final_canteen/model/menu_item_model.dart';
import 'package:final_canteen/model/parent_category_model.dart';
import 'package:final_canteen/services/child_category_services.dart';
import 'package:final_canteen/services/item_services.dart';
import 'package:final_canteen/services/parent_category_services.dart';
import 'package:final_canteen/staff_modules/widgets/addStock_item_card.dart';
import 'package:final_canteen/staff_modules/widgets/add_subCategory.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';

class StockMngmnt extends StatefulWidget {
  final double navbarHeight;
  const StockMngmnt({super.key, required this.navbarHeight});

  @override
  State<StockMngmnt> createState() => _StockMngmntState();
}


class _StockMngmntState extends State<StockMngmnt> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{

  final ParentCategoryApiServices _parentCategoryApiService = ParentCategoryApiServices();
  final ItemService _itemService = ItemService();
  final CategoryService _childCategoryService = CategoryService();

  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  final TextEditingController itemStockController = TextEditingController();
  final TextEditingController itemDescController = TextEditingController();

  List<ShowParentCategory> categories = [];
  List<ItemByCategory> items = [];
  List<Childcategory> childCategories = [];
  List<ShowParentCategory> parentCategoriesForItems = [];
  List<String> parentCategoryNames = [];
  List<ShowParentCategory> parentCategoriesForStock = [];


  bool isSelected = false;
  TabController? _tabController;
  int _selectedIndex = 0;

  String selectedParentForItem = "Ulam";
  String selectedParentForStock = "Ulam";
  String defaultValue = "Ulam";
  String? selectedChildCategoryId;
  String? categoryId;


  
@override
  bool get wantKeepAlive => true;

@override
void initState() {
  super.initState();
  categoryNameTOcategoryId();
  fetchParentCategories();
  fetchChildCategories();
  fetchMenuItemsByParentCategory();
  _tabController = TabController(length: 2, vsync: this);
}


Future<void> addItem() async {
  double itemPrice = double.parse(itemPriceController.text);
  int itemStock = int.parse(itemStockController.text);
  try {
    await _itemService.addStock(
      itemNameController.text,
      itemDescController.text,
      itemPrice,
      selectedChildCategoryId!,
      itemStock,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Item Name: ${itemNameController.text}\n"
          "Description: ${itemDescController.text}\n"
          "Price: $itemPrice\n"
          "Category ID: $selectedChildCategoryId\n"
          "Stock: $itemStock",
        ),
      ),
    );

    itemNameController.clear();
    itemDescController.clear();
    itemPriceController.clear();
    itemStockController.clear();
    selectedChildCategoryId = null;

    await fetchMenuItemsByParentCategory();
    

    setState(() {});
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to update stock: $e")),
    );
  }
}


void addSubCategory() {
  showDialog(
    context: context,
    builder: (context) => AddSubcategory(selectedParentCategoryName: selectedParentForItem),
  );
}

void fetchChildCategories() async {

  List<Childcategory> childCategory = await _childCategoryService.fetchChildCategories(selectedParentForItem);

  if(mounted){
    setState(() {
    childCategories = childCategory;
  });
  }


}

void fetchParentCategories() async {
  
  List<ShowParentCategory> category = await _parentCategoryApiService.fetchParentCategories();

  if (mounted) {
    setState(() {
      parentCategoriesForStock = category;
      parentCategoriesForItems = category;
      parentCategoryNames = parentCategoriesForItems.map((c) => c.categoryName).toList();
    });

    
    if (_tabController == null) {
      _tabController = TabController(length: 2, vsync: this);
      
      
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          setState(() {
            _selectedIndex = _tabController!.index;
          });
          fetchMenuItemsByParentCategory();
        }
      });
    }

    
    if (parentCategoriesForItems.isNotEmpty) {
      fetchMenuItemsByParentCategory();
    }
  }
}


void categoryNameTOcategoryId() {
switch (selectedParentForStock.toLowerCase()) {
  case 'ulam':
    categoryId = '899BD3DD-8C14-438A-A971-3DFE4D2CA327'; 
    break;
  case 'meryenda':
    categoryId = '482F2A5E-97FC-4BE0-AB18-404A036404ED'; 
    break;
  case 'drinks':
    categoryId = 'D25897BE-5779-4379-8625-EA236426EB90'; 
    break;
  default:
    categoryId = '0'; 
    break;
}

fetchMenuItemsByParentCategory();
}



Future<void> fetchMenuItemsByParentCategory() async {
  if (categoryId == null) {
    print("No category ID found");
    return;
  }

  try {
    List<ItemByCategory> fetchedItems = await _itemService.fetchMenuItemsByParentCategory(categoryId!);
    if (mounted) {
      setState(() {
        items = fetchedItems;
        print("Fetched items: $items");
      });
    }
  } catch (e) {
    print("Error fetching menu items: $e");
  }
}


@override
Widget build(BuildContext context) {
  print("Items count: ${items.length}");

  print(categoryId);
  return Scaffold(
    backgroundColor: Colors.white,
    body: LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;

        return isDesktop
            ? Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                  children: [
                    Expanded(flex: 2, child: _buildStockGrid()),
                    Expanded(flex: 3, child: _buildMainSection()),
                  ],
                ),
            )
            : Column(
                children: [
                  const SizedBox(height: 30),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: "Add Stock"),
                      Tab(text: "Add Item"),
                    ],
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildStockGrid(),
                        SingleChildScrollView(
                          child: _buildMainSection(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
      },
    ),
  );
}

Widget _buildMainSection() {
  return LayoutBuilder(
    builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth > 700;
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
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.inventory_2, color: AppColors.primary,),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Add New Stock",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary
                    ),
                  ),
                ),
              ],
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: buildTextField(
                color: const Color.fromARGB(255, 0, 0, 0),
                controller: itemNameController,
                label: "Item Name",
                icon: Icons.fastfood,
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: buildNumberTextField(
                color: const Color.fromARGB(255, 0, 0, 0),
                controller: itemPriceController,
                label: "Price",
                icon: Icons.attach_money,
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: buildNumberTextField(
                color: const Color.fromARGB(255, 0, 0, 0),
                controller: itemStockController,
                label: "Stock Quantity",
                icon: Icons.inventory,
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Select Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: DropdownButtonHideUnderline(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: selectedParentForItem ?? defaultValue,
                    items: parentCategoryNames.map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Row(
                          children: [
                            Icon(Icons.restaurant, size: 20, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(name, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedParentForItem = newValue!;
                        selectedChildCategoryId = null;
                      });
                      fetchChildCategories();
                    },
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Select Subcategory",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DropdownButtonFormField<String>(
                value: selectedChildCategoryId,
                hint: Text("Select Subcategory"),
                onChanged: (value) {
                  setState(() {
                    selectedChildCategoryId = value;
                  });
                },
                items: childCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.categoryName),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subdirectory_arrow_right, color: AppColors.primary),
                ),
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: buildLargeTextField(
                color: const Color.fromARGB(255, 0, 0, 0),
                controller: itemDescController,
                hintText: "Item Description",
              ),
            ),

            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedChildCategoryId != null && selectedChildCategoryId!.isNotEmpty
                        ? addItem
                        : null,
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      "Add Item",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildStockGrid() {
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
                  child: Icon(Icons.inventory_rounded, color: AppColors.primary,),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Manage Stock",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary
                    ),
                  ),
                ),

              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DropdownButtonFormField<String>(
                
                dropdownColor: Colors.white,
                value: parentCategoriesForStock.any((c) => c.categoryName == selectedParentForStock) ? selectedParentForStock : null,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedParentForStock = newValue!;
                  });
                  categoryNameTOcategoryId();
                  fetchChildCategories();
                  fetchMenuItemsByParentCategory();
                },
                items: parentCategoriesForStock.map((category) {
                  return DropdownMenuItem(
                    value: category.categoryName,
                    child: Text(category.categoryName),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "Select Category",
                  labelStyle: TextStyle(color: AppColors.primary),
                  border: OutlineInputBorder(
                    
                  ),
                ),
              ),
            ),

            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("No items found."))
                  : GridView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 2 : 1,
                        childAspectRatio: isDesktop ? 0.9 : 1.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return AddstockItemCard(
                          itemName: item.itemName,
                          stock: item.stock,
                          id: item.id,
                          description: item.description,
                          price: item.price.toDouble(),
                          categoryId: item.categoryId,
                          featuredStartTime: item.featuredStartTime,
                          featuredEndTime: item.featuredEndTime,
                          onStockUpdated: () {
                            setState(() {
                              fetchMenuItemsByParentCategory();
                              categoryNameTOcategoryId();
                            });
                          },
                          onFeaturedToggled: (isFeatured) {
                            fetchMenuItemsByParentCategory();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

Widget buildLargeTextField({
      required TextEditingController controller,
      required String hintText,
      required Color color,
      IconData? icon,
    }) {
      return TextField(
        controller: controller,
        maxLines: 3, 
        decoration: InputDecoration(
          labelStyle: TextStyle(color: color),
          labelText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
          alignLabelWithHint: true, 
        ),
      );
    }

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required Color color,
  IconData? icon,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelStyle: TextStyle(color: color),
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primary,) : null,
    ),
  );
}

Widget buildNumberTextField({
  required TextEditingController controller,
  required String label,
  required Color color,
  IconData? icon,
}) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelStyle: TextStyle(color: color),
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      prefixIcon: icon != null ? Icon(icon,color: AppColors.primary) : null,
    ),
  );
}


}
