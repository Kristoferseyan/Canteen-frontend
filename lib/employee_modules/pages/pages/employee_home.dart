// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:final_canteen/model/parent_category_model.dart';
import 'package:final_canteen/employee_modules/pages/pages/child_menu.dart';
import 'package:final_canteen/services/parent_category_services.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:final_canteen/model/menu_item_model.dart';
import 'package:final_canteen/services/item_services.dart';

class EmployeeHome extends StatefulWidget {
  final double navbarHeight;

  const EmployeeHome({super.key, required this.navbarHeight});

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  String _selectedCategory = '';
  final ParentCategoryApiServices _apiServices = ParentCategoryApiServices();
  List<ShowParentCategory> parentCategories = [];
  final ItemService _itemService = ItemService();
  List<ItemByCategory> _featuredItems = [];
  bool _isLoadingFeatured = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
    _loadFeaturedItems();
  }

Future<void> loadCategories() async {
  List<ShowParentCategory> categories = await _apiServices.fetchParentCategories();

  if (mounted) {
    setState(() {
      parentCategories = categories;
    });
  }
}

Future<void> _loadFeaturedItems() async {
  setState(() {
    _isLoadingFeatured = true;
  });
  
  try {
    final items = await _itemService.fetchFeaturedItems();
    
    if (mounted) {
      setState(() {
        _featuredItems = items;
        _isLoadingFeatured = false;
      });
    }
  } catch (e) {
    print("Error loading featured items: $e");
    
    if (mounted) {
      setState(() {
        _isLoadingFeatured = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 700;
    return Scaffold(
      backgroundColor:Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 700;
          double availableHeight = constraints.maxHeight - widget.navbarHeight;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: featuredBox("Featured Foods", availableHeight),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: menuBox("Food Categories", availableHeight,width * 0.5 , isDesktop),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              featuredBox("Featured Foods", availableHeight * 0.4),
                              SizedBox(height: 16),
                              menuBox("Food Categories", availableHeight * 0.6, width * 1.6, isDesktop),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget featuredBox(String title, double height) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 700;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDesktop 
                ? Colors.grey.withOpacity(0.5) 
                : const Color.fromARGB(0, 210, 210, 210).withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          )
        ],
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isDesktop ? 30 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 186, 26, 15),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: AppColors.primary),
                    onPressed: _loadFeaturedItems,
                    tooltip: "Refresh featured items",
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _buildFeaturedItemsContent(isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedItemsContent(bool isDesktop) {
    if (_isLoadingFeatured) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              "Loading featured items...",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    if (_featuredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "No featured items available",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Featured items will appear here when available.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    
    return isDesktop
        ? GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemCount: _featuredItems.length,
            itemBuilder: (context, index) {
              return _buildFeaturedItemCard(_featuredItems[index]);
            },
          )
        : ListView.builder(
          padding: EdgeInsets.zero,
            itemCount: _featuredItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _buildFeaturedItemCard(_featuredItems[index]),
              );
            },
          );
  }

  Widget _buildFeaturedItemCard(ItemByCategory item) {
    final now = DateTime.now();
    final timeRemaining = item.featuredEndTime != null 
        ? item.featuredEndTime!.difference(now)
        : Duration.zero;
    
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Featured",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₱${item.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.stock > 5 ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.stock > 0 ? "In Stock: ${item.stock}" : "Out of Stock",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: item.stock > 5 ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("View Details"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget menuBox(String title, double height, double width, bool isDesktop) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: const Color.fromARGB(255, 186, 26, 15),),
                  SizedBox(width: 10,),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isDesktop ? 30 : 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 186, 26, 15),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 2 : 1,
                  crossAxisSpacing: isDesktop ? 20 : 10,
                  mainAxisSpacing: isDesktop ? 20 : 10,
                  childAspectRatio: isDesktop ? 2.5 : 2.2,
                ),
                itemCount: parentCategories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = parentCategories[index].categoryName;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChildMenu(selectedCategory: _selectedCategory),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          parentCategories[index].categoryName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}