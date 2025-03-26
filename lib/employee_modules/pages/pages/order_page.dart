import 'package:final_canteen/providers/user_provider.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:final_canteen/model/order_summary_model.dart';
import 'package:final_canteen/employee_modules/pages/widgets/order_card.dart';
import 'package:final_canteen/services/order_summary_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  final double navbarHeight;
  const OrderPage({super.key, required this.navbarHeight});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  final OrderSummaryService _orderSummaryService = OrderSummaryService();
  final ScrollController _scrollController = ScrollController();
  
  late TabController _tabController;
  
  final Map<String, List<OrderSummaries>> _ordersByStatus = {
    'Pending': [],
    'Processing': [],
    'Ready': [],
    'Completed': [],
  };
  
  final Map<String, int> _pageByStatus = {
    'Pending': 0,
    'Processing': 0,
    'Ready': 0,
    'Completed': 0,
  };

  final int _itemsPerPage = 10;  

  bool _isLoading = true;
  bool _hasInitialized = false;
  String? _userId;
  String? _errorMessage;
  int _initAttempts = 0;
      
  final Map<String, bool> _isLoadingStatus = {
    'Pending': false,
    'Processing': false,
    'Ready': false,
    'Completed': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    
    if (!_hasInitialized) {
      _initializeData();
    }
  }

  void _initializeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      
      if (storedUserId != null && storedUserId.isNotEmpty) {
        if (mounted) {
          setState(() {
            _userId = storedUserId;
            _hasInitialized = true;
            _isLoading = false;
            _errorMessage = null;
          });
          
          
          _fetchOrdersByStatus(_getStatusFromTabIndex(_tabController.index));
          return; 
        }
      }
    } catch (e) {
      print("Error accessing SharedPreferences: $e");
      
    }
    if (!mounted) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.isLoading && userProvider.userId != null) {
      
      setState(() {
        _userId = userProvider.userId;
        _hasInitialized = true;
        _isLoading = false;
        _errorMessage = null;
      });
      _fetchOrdersByStatus(_getStatusFromTabIndex(_tabController.index));
    } else if (!userProvider.isLoading && userProvider.userId == null) {
      
      setState(() {
        _isLoading = false;
        _hasInitialized = false;
        _errorMessage = "User not authenticated. Please login again.";
      });
    } else {
      
      
      _initAttempts++;
      
      if (_initAttempts < 5) { 
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            _initializeData(); 
          }
        });
      } else {
        
        setState(() {
          _isLoading = false;
          _errorMessage = "Couldn't load user data. Please try again.";
        });
      }
    }
  }

  Future<void> _fetchOrdersByStatus(String status) async {
    if (_userId == null || _userId!.isEmpty) {
      setState(() {
        _errorMessage = "User ID not available. Please login again.";
        _isLoadingStatus[status] = false;
      });
      return;
    }

    setState(() {
      _isLoadingStatus[status] = true;
    });
    
    try {
      final orders = await _orderSummaryService.fetchOrderSummary(
        _userId!, 
        status, 
        _pageByStatus[status]! + 1, 
        _itemsPerPage
      );
      
      if (mounted) {
        setState(() {
          _ordersByStatus[status] = orders;
          _isLoadingStatus[status] = false;
        });
      }
    } catch (e) {
      print("Error fetching $status orders: $e");
      if (mounted) {
        setState(() {
          _isLoadingStatus[status] = false;
          _errorMessage = "Failed to load $status orders. Please try again.";
        });
      }
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    
    final String status = _getStatusFromTabIndex(_tabController.index);
    if (_ordersByStatus[status]!.isEmpty && !_isLoadingStatus[status]!) {
      _fetchOrdersByStatus(status);
    }
  }
  
  String _getStatusFromTabIndex(int index) {
    switch (index) {
      case 0: return 'Pending';
      case 1: return 'Processing';
      case 2: return 'Ready';
      case 3: return 'Completed';
      default: return 'Pending';
    }
  }

  Future<void> _fetchAllOrders() async {
    
    if (_userId == null || _userId!.isEmpty) {
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final storedUserId = prefs.getString('userId');
        
        if (storedUserId != null && storedUserId.isNotEmpty) {
          setState(() {
            _userId = storedUserId;
            _hasInitialized = true;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = "User not authenticated. Please login again.";
          });
          return;
        }
      } catch (e) {
        print("Error accessing SharedPreferences: $e");
        setState(() {
          _errorMessage = "Error accessing user data. Please try again.";
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await Future.wait([
        _fetchOrdersByStatus('Pending'),
        _fetchOrdersByStatus('Processing'),
        _fetchOrdersByStatus('Ready'),
        _fetchOrdersByStatus('Completed'),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching orders: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load orders. Please try again.";
        });
      }
    }
  }

  void _handlePageChange(String status, bool isNext) {
    setState(() {
      final currentPage = _pageByStatus[status]!;
      _pageByStatus[status] = isNext 
          ? currentPage + 1 
          : (currentPage > 0 ? currentPage - 1 : 0);
    });
    _fetchOrdersByStatus(status);
  }

  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 900;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding:isDesktop ? const EdgeInsets.only(top: 0.0) : const EdgeInsets.only(top: 50.0),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: const Icon(Icons.pending_actions),
                  text: "Pending${_ordersByStatus['Pending']!.isNotEmpty ? ' (${_ordersByStatus['Pending']!.length})' : ''}",
                ),
                Tab(
                  icon: const Icon(Icons.sync),
                  text: "Processing${_ordersByStatus['Processing']!.isNotEmpty ? ' (${_ordersByStatus['Processing']!.length})' : ''}",
                ),
                Tab(
                  icon: const Icon(Icons.local_shipping),
                  text: "Ready${_ordersByStatus['Ready']!.isNotEmpty ? ' (${_ordersByStatus['Ready']!.length})' : ''}",
                ),
                Tab(
                  icon: const Icon(Icons.check_circle),
                  text: "Completed${_ordersByStatus['Completed']!.isNotEmpty ? ' (${_ordersByStatus['Completed']!.length})' : ''}",
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllOrders,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _errorMessage != null && !_hasInitialized
                ? _buildErrorWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList('Pending', isDesktop),
                      _buildOrderList('Processing', isDesktop),
                      _buildOrderList('Ready', isDesktop),
                      _buildOrderList('Completed', isDesktop),
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            _errorMessage ?? "An error occurred",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _initializeData(), 
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Try Again", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status, bool isDesktop) {
    final orders = _ordersByStatus[status]!;
    final isLoading = _isLoadingStatus[status]!;
    final currentPage = _pageByStatus[status]!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          _buildStatusHeader(status, orders.length),
          
          const SizedBox(height: 16),
          
          
          Expanded(
            child: _buildOrdersContent(status, orders, isLoading, isDesktop),
          ),
          
          
          _buildPaginationControls(status, orders.length, currentPage),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(String status, int count) {
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'Pending':
        statusColor = Colors.amber;
        statusIcon = Icons.pending_actions;
        break;
      case 'Processing':
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        break;
      case 'Ready':
        statusColor = Colors.green;
        statusIcon = Icons.local_shipping;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 6),
              Text(
                "$status Orders",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          "$count ${count == 1 ? 'Order' : 'Orders'}",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _fetchOrdersByStatus(status),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh $status orders",
          color: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildOrdersContent(String status, List<OrderSummaries> orders, bool isLoading, bool isDesktop) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    
    if (orders.isEmpty) {
      return _buildEmptyState(status);
    }
    
    
    final crossAxisCount = isDesktop ? 2 : 1;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 2.2 : 1.8,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        
        return OrderCard(
          order: order, 
          orderId: order.id,
        );
      },
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyStateIcon(status),
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No $status Orders",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(status),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _fetchOrdersByStatus(status),
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getEmptyStateIcon(String status) {
    switch (status) {
      case 'Pending': return Icons.pending_actions;
      case 'Processing': return Icons.sync;
      case 'Ready': return Icons.local_shipping;
      case 'Completed': return Icons.check_circle;
      default: return Icons.info_outline;
    }
  }
  
  String _getEmptyStateMessage(String status) {
    switch (status) {
      case 'Pending': return 'No pending orders waiting for approval.';
      case 'Processing': return 'No orders currently being processed.';
      case 'Ready': return 'No orders ready for pickup or delivery.';
      case 'Completed': return 'No orders have been completed yet.';
      default: return 'No orders to display.';
    }
  }

  Widget _buildPaginationControls(String status, int itemCount, int currentPage) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: currentPage > 0 ? () => _handlePageChange(status, false) : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text("Previous"),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage > 0 ? AppColors.secondary : Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: currentPage > 0 ? 2 : 0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Page ${currentPage + 1}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: itemCount == _itemsPerPage ? () => _handlePageChange(status, true) : null,
            icon: const Text("Next"),
            label: const Icon(Icons.arrow_forward),
            style: ElevatedButton.styleFrom(
              backgroundColor: itemCount == _itemsPerPage ? AppColors.secondary : Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: itemCount == _itemsPerPage ? 2 : 0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

}