import 'package:final_canteen/employee_modules/pages/widgets/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:final_canteen/model/menu_item_model.dart';
import 'package:final_canteen/model/child_category_model.dart';
import 'package:final_canteen/services/item_services.dart';
import 'package:final_canteen/services/child_category_services.dart';
import 'package:final_canteen/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ChildMenu extends StatefulWidget {
  final String selectedCategory;
  const ChildMenu({super.key, required this.selectedCategory});

  @override
  State<ChildMenu> createState() => _ChildMenuState();
}

class _ChildMenuState extends State<ChildMenu> with TickerProviderStateMixin {
  final CategoryService _categoryService = CategoryService();
  final ItemService _itemService = ItemService();
  late TabController _tabController;

  List<Childcategory> allCategories = [];
  List<ItemByCategory> menuItems = [];
  List<String> tabNames = ["All"];

  String selectedTab = "All";
  bool isLoading = true;
  bool isSearching = false;
  String searchQuery = '';

  Map<String, int> tempStocks = {};
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> openCart() {
    return showDialog(
      context: context,
      builder: (context) => CartScreen(),
    );
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      final categories =
          await _categoryService.fetchChildCategories(widget.selectedCategory);
      setState(() {
        allCategories = categories;
        tabNames = [
          "All",
          ...categories.map((c) => c.categoryName ?? "").toSet().toList()
        ];
        selectedTab = "All";
        _tabController = TabController(length: tabNames.length, vsync: this);
      });
      _loadAllItemsForParentCategory(widget.selectedCategory);
    } catch (e) {
      print("Error loading categories: $e");
      setState(() {
        allCategories = [];
        tabNames = ["All"];
        menuItems = [];
        _tabController = TabController(length: 1, vsync: this);
      });
      _showErrorSnackBar("Failed to load categories");
    }
    setState(() => isLoading = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadCategories,
        ),
      ),
    );
  }

  Future<void> _loadAllItemsForParentCategory(String parentCategory) async {
    setState(() => isLoading = true);
    try {
      final allItems = <ItemByCategory>[];
      for (var category in allCategories) {
        final items =
            await _itemService.fetchMenuItemsByCategory(category.id ?? "");
        allItems.addAll(items);
      }
      setState(() {
        menuItems = allItems;

        tempStocks = {
          for (var item in menuItems) item.id!: item.stock,
        };
      });
    } catch (e) {
      print("Error loading all items for parent category: $e");
      setState(() => menuItems = []);
      _showErrorSnackBar("Failed to load menu items");
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadItems(String categoryId) async {
    setState(() => isLoading = true);
    try {
      final items = await _itemService.fetchMenuItemsByCategory(categoryId);
      setState(() {
        menuItems = items;
        tempStocks = {
          for (var item in menuItems) item.id: item.stock,
        };
      });
    } catch (e) {
      print("Error loading items: $e");
      setState(() => menuItems = []);
      _showErrorSnackBar("Failed to load items for this category");
    }
    setState(() => isLoading = false);
  }

  void _addToCart(BuildContext context, ItemByCategory item, int quantity) {
    Provider.of<CartProvider>(context, listen: false).addItem(
      item.id,
      item.itemName ?? "Unknown item",
      quantity,
      item.price,
    );
  }

  void _decreaseTempStock(String itemId) {
    if (tempStocks.containsKey(itemId) && tempStocks[itemId]! > 0) {
      setState(() {
        tempStocks[itemId] = tempStocks[itemId]! - 1;
      });
    }
  }

  void _handleCategorySelection(int index) {
    setState(() {
      selectedTab = tabNames[index];
    });

    if (selectedTab == "All") {
      _loadAllItemsForParentCategory(widget.selectedCategory);
    } else {
      final selectedCategory = allCategories.firstWhere(
        (c) => c.categoryName == selectedTab,
        orElse: () => Childcategory(id: "", categoryName: ""),
      );
      _loadItems(selectedCategory.id ?? "");
    }
  }

  List<ItemByCategory> _getFilteredItems() {
    if (searchQuery.isEmpty) return menuItems;
    return menuItems
        .where((item) => item.itemName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;
    final cartProvider = Provider.of<CartProvider>(context);
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: isSearching
            ? _buildSearchField()
            : Text(widget.selectedCategory, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = '';
                }
              });
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 28),
                onPressed: openCart,
              ),
              if (cartProvider.cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      cartProvider.cartItems.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: isDesktop
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: AppColors.primary,
                  child: TabBar(
                    labelColor: Colors.white,
                    controller: _tabController,
                    onTap: _handleCategorySelection,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                    ),
                    tabs: tabNames
                        .map((name) => Tab(
                              text: name,
                            ))
                        .toList(),
                  ),
                ),
              )
            : PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.primary,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTab,
                        isExpanded: true,
                        dropdownColor: AppColors.primary,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            final index = tabNames.indexOf(newValue);
                            if (index >= 0) {
                              _handleCategorySelection(index);
                            }
                          }
                        },
                        items: tabNames.map<DropdownMenuItem<String>>((String name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : filteredItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        searchQuery.isEmpty ? Icons.restaurant_menu : Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isEmpty
                            ? "No items available in this category"
                            : "No results found for \"$searchQuery\"",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (searchQuery.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                              isSearching = false;
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text("Clear search"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                )
              : SafeArea(
                  child: isDesktop 
                    ? Column(
                        children: [
                          Expanded(
                            child: _buildGridMenu(filteredItems),
                          ),
                          _buildCartSummary(context),
                        ],
                      )
                    : Stack(
                        children: [
                          
                          Container(
                            height: MediaQuery.of(context).size.height,
                            padding: EdgeInsets.only(
                              bottom: cartProvider.cartItems.isEmpty ? 0 : 140,
                            ),
                            child: _buildListMenu(filteredItems),
                          ),
                          
                          if (cartProvider.cartItems.isNotEmpty)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: _buildCartSummary(context),
                            ),
                        ],
                      ),
                ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Search items...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        border: InputBorder.none,
      ),
      onChanged: (query) => setState(() => searchQuery = query),
    );
  }

  Widget _buildGridMenu(List<ItemByCategory> items) {
    return AnimationLimiter(
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 4,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildMenuItemCard(items[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListMenu(List<ItemByCategory> items) {
    return AnimationLimiter(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildMenuItemCard(items[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItemCard(ItemByCategory item) {
    final stockLevel = tempStocks[item.id] ?? 0;
    bool isOutOfStock = stockLevel <= 0;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Card(
      color: Colors.white,
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isOutOfStock ? const Color.fromARGB(255, 170, 90, 98) : Colors.transparent,
          width: isOutOfStock ? 1 : 0,
        ),
      ),
      child: SingleChildScrollView(
        physics: isSmallScreen ? null : NeverScrollableScrollPhysics(),
        child: Stack(
          children: [
            if (isOutOfStock)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "OUT OF STOCK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(
                minHeight: isSmallScreen ? 200 : 300,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Container(
                    color: const Color.fromARGB(255, 242, 63, 51),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      item.itemName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Content area
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Use min to prevent expansion
                      children: [
                        // Price
                        Center(
                          child: Text(
                            "₱${item.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description
                        Center(
                          child: Text(
                            item.description ?? "No description available",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Stock indicator and add button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStockLevelColor(stockLevel).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStockLevelIcon(stockLevel),
                                    size: 14,
                                    color: _getStockLevelColor(stockLevel),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Stock: $stockLevel",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getStockLevelColor(stockLevel),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            ElevatedButton.icon(
                              onPressed: isOutOfStock
                                  ? null
                                  : () {
                                      _addToCart(context, item, 1);
                                      _decreaseTempStock(item.id!);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                              label: const Text(
                                "Add",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Color _getStockLevelColor(int stock) {
    if (stock <= 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  IconData _getStockLevelIcon(int stock) {
    if (stock <= 0) return Icons.remove_shopping_cart;
    if (stock <= 5) return Icons.warning_amber;
    return Icons.check_circle;
  }

  Widget _buildCartSummary(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.cartItems.isEmpty) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cart Summary",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₱${cart.getTotalAmount().toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: openCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.shopping_cart, 
                  color: Colors.white,),
                label: Text(
                  "View Cart (${cart.cartItems.length})",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}