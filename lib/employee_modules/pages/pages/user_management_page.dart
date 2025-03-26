import 'package:final_canteen/model/order_model.dart';
import 'package:final_canteen/model/user_model.dart';
import 'package:final_canteen/services/order_service.dart';
import 'package:final_canteen/services/user_payment_service.dart';
import 'package:final_canteen/services/user_services.dart';
import 'package:final_canteen/staff_modules/widgets/completed_order_receipt.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserApiServices _userApiServices = UserApiServices();
  final OrderService _orderService = OrderService();

  List<Order> _completedOrders = [];

  User? currentUser;
  String userId = "";
  bool isLoading = true;
  String? error;
  double sdBalance = 0;

  String _getFullName() {
    String firstName = currentUser?.firstName ?? '';
    String lastName = currentUser?.lastName ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    }

    return 'User';
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCompletedOrders();
  }

  void _loadUser() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');

      if (storedUserId == null) {
        setState(() {
          isLoading = false;
          error = "User ID not found. Please log in again.";
        });
        return;
      }

      setState(() {
        userId = storedUserId;
      });

      User loadedUser = await _userApiServices.fetchUserById(userId);

      if (mounted) {
        setState(() {
          currentUser = loadedUser;
          isLoading = false;
        });
        getSDBalanceById(userId);
      }
    } catch (e) {
      print('Error loading user: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          error = "Failed to load user data: $e";
        });
      }
    }
  }

  Future<void> getSDBalanceById(String id) async {
    try {
      final balance = await UserPaymentService().fetchUnpaidSDBalance(id);

      if (mounted) {
        setState(() {
          sdBalance = balance;
        });
      }
    } catch (e) {
      print("Error fetching SD balance: $e");
      if (mounted) {
        setState(() {
          sdBalance = 0.0;
        });
      }
    }
  }

  void _loadCompletedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');

    if (storedUserId == null) {
      setState(() {
        isLoading = false;
        error = "User ID not found. Please log in again.";
      });
      return;
    }

    setState(() {
      userId = storedUserId;
    });

    final completedOrders =
        await _orderService.fetchCompletedOrdesByUserId(userId);
    if (mounted) {
      setState(() {
        _completedOrders = completedOrders;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? _buildLoadingState()
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: _buildUserHeader(),
                  ),
                  Expanded(
                    child: isWideScreen
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: _buildProfileBox(),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 14.0, right: 14.0),
                                  child: _buildRecentOrder(),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: _buildProfileBox(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 14.0, right: 14.0),
                                  child: _buildRecentOrder(),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: _buildSDBalanceBox(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 20),
          Text(
            "Loading user profile...",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        padding: EdgeInsets.symmetric(vertical: 30),
        color: AppColors.primary,
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              _getFullName(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              currentUser?.username ?? "Username not available",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrder() {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 800;

    return Container(
      height: isWideScreen ? screenSize.height * 0.48 : screenSize.height * 0.5,
      width: isWideScreen ? screenSize.width * 0.58 : screenSize.width * 0.9,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(1, 1))
        ],
      ),
      child: Card(
        color: const Color.fromARGB(255, 255, 254, 254),
        margin: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recent Orders",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Divider(
                height: 30,
              ),
              Expanded(
                child: _completedOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              "No recent orders",
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        scrollDirection:
                            isWideScreen ? Axis.horizontal : Axis.vertical,
                        itemCount: _completedOrders.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: isWideScreen ? 320 : double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 12,
                                left: 12,
                                bottom: 6,
                                top: 6,
                              ),
                              child: _buildRecentOrderBox(index),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrderBox(int index) {
    var screenSize = MediaQuery.of(context).size;
    bool isWideScreen = screenSize.width > 700;

    final orderDate = _completedOrders[index].orderDate;
    final formattedDate = orderDate != null
        ? "${orderDate.day}/${orderDate.month}/${orderDate.year} at ${orderDate.hour}:${orderDate.minute.toString().padLeft(2, '0')}"
        : "Date unavailable";
    IconData paymentIcon =
        _completedOrders[index].paymentMethod?.toLowerCase() == "sd"
            ? Icons.school
            : Icons.payments;

    return Container(
      width: isWideScreen ? 280 : null,
      padding: isWideScreen
          ? const EdgeInsets.only(left: 10, right: 10)
          : const EdgeInsets.only(top: 10, bottom: 10),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "#${_completedOrders[index].shortId!.toUpperCase()}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          paymentIcon,
                          size: 20,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Payment",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _completedOrders[index]
                                      .paymentMethod
                                      ?.toUpperCase() ??
                                  "Unknown",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CompletedOrderReceipt(
                        orderId: _completedOrders[index].id ?? "",
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt),
                  label: const Text("VIEW RECEIPT"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSDBalanceBox() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 380;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 2))
        ],
      ),
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isSmallScreen
              ? _buildSDBalanceCompactLayout()
              : _buildSDBalanceRegularLayout(),
        ),
      ),
    );
  }

  Widget _buildSDBalanceRegularLayout() {
    return Row(
      children: [
        Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 28),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Unpaid SD Balance",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                sdBalance > 0
                    ? "You have an outstanding balance to settle"
                    : "No outstanding balance",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text(
          "₱${sdBalance.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: sdBalance > 0 ? Colors.red[700] : Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildSDBalanceCompactLayout() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet,
                color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              "Unpaid SD Balance",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          "₱${sdBalance.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: sdBalance > 0 ? Colors.red[700] : Colors.green[700],
          ),
        ),
        SizedBox(height: 4),
        Text(
          sdBalance > 0
              ? "Outstanding balance to settle"
              : "No outstanding balance",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileBox() {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 800;

    return Container(
      height:
          isWideScreen ? screenSize.height * 0.45 : screenSize.height * 0.37,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 3,
          )
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Personal Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Divider(height: 30),
            _buildInfoRow(
                "First Name", currentUser?.firstName ?? "Not available"),
            _buildInfoRow(
                "Last Name", currentUser?.lastName ?? "Not available"),
            _buildInfoRow("Username", currentUser?.username ?? "Not available"),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print("");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child:
                    Text("Edit Profile", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ":",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
