

import 'package:final_canteen/model/userPayment_details_model.dart';
import 'package:final_canteen/services/user_payment_service.dart';
import 'package:final_canteen/staff_modules/widgets/userPayment_details_box.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';

class UserPaymentsPage extends StatefulWidget {
  final int navbarHeight;
  const UserPaymentsPage({super.key, required this.navbarHeight});

  @override
  State<UserPaymentsPage> createState() => _UserPaymentsPageState();
}

class _UserPaymentsPageState extends State<UserPaymentsPage> {
  final UserPaymentService _userPaymentService = UserPaymentService();

  TextEditingController searchController = TextEditingController();

  List<UPDetails> allPayments = [];
  List<UPDetails> filteredPayments = [];

  bool isLoading = true;
  bool hasError = false;

  String selectedPaymentMethod = 'All';
  String selectedPaymentStatus = 'All';

  int pageSize = 10;
  int pageNumber = 1;
  bool hasMoreItems = true;

  double totalSDAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchUserPaymentDetails();
  }

  Future<void> fetchUserPaymentDetails({
    String? paymentMethod,
    String? paymentStatus,
    String? name,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    setState(() => isLoading = true);

    try {
      paymentMethod ??= selectedPaymentMethod;
      paymentStatus ??= selectedPaymentStatus;
      name ??= searchController.text;

      final fetchedPayments = await _userPaymentService.fetchUPDetails(
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        name: name,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      setState(() {
        allPayments = fetchedPayments;
        filteredPayments = fetchedPayments;
        hasMoreItems = fetchedPayments.length >= pageSize;
      });
      
      
      if (paymentMethod == 'SD' && paymentStatus == 'Unpaid') {
        try {
          final unpaidSDBalance = await _userPaymentService.getUnpaidSDBalanceByName(name);
          setState(() {
            totalSDAmount = unpaidSDBalance.data ?? 0.0;
            print("Total SD Amount: $totalSDAmount"); 
          });
        } catch (balanceError) {
          print("Error fetching SD balance: $balanceError");
          
        }
      } else {
        setState(() {
          totalSDAmount = 0.0; 
        });
      }
    } catch (e) {
      if(mounted){
      setState(() {
        hasError = true;
      });
      }

      print("Error fetching payments: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height - widget.navbarHeight;
    bool isDesktop = screenHeight > 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: screenHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDesktop
                    ? const Color.fromARGB(0, 248, 248, 248).withOpacity(0.1)
                    : const Color.fromARGB(0, 255, 254, 254).withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.payment, color: AppColors.primary, size: 28,),
                    ) ,
                    Text(
                      "User Payments",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(indent: 40, endIndent: 40, thickness: 1),
              _buildSearchSection(),
              _buildSummaryBox(), 
              Expanded(child: _buildPaymentList()),
              _buildPaginationControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    bool isDesktop = MediaQuery.of(context).size.width >= 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search by Name',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedPaymentMethod,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPaymentMethod = newValue ?? 'All';
                    });
                  },
                  items: <String>['All', 'Cash', 'SD']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedPaymentStatus,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPaymentStatus = newValue ?? 'All';
                    });
                  },
                  items: <String>['All', 'Paid', 'Unpaid']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    fetchUserPaymentDetails(
                      paymentMethod: selectedPaymentMethod,
                      paymentStatus: selectedPaymentStatus,
                      name: searchController.text,
                      pageNumber: 1,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search by Name',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPaymentMethod,
                            isDense: true,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPaymentMethod = newValue ?? 'All';
                              });
                            },
                            items: <String>['All', 'Cash', 'SD']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPaymentStatus,
                            isDense: true,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPaymentStatus = newValue ?? 'All';
                              });
                            },
                            items: <String>['All', 'Paid', 'Unpaid']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      fetchUserPaymentDetails(
                        paymentMethod: selectedPaymentMethod,
                        paymentStatus: selectedPaymentStatus,
                        name: searchController.text,
                        pageNumber: 1,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Search", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: pageNumber > 1
                ? () {
                    setState(() {
                      pageNumber--;
                    });
                    fetchUserPaymentDetails(
                      paymentMethod: selectedPaymentMethod,
                      paymentStatus: selectedPaymentStatus,
                      name: searchController.text,
                      pageNumber: pageNumber,
                    );
                  }
                : null,
          ),
          Text('Page $pageNumber'),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: hasMoreItems
                ? () {
                    setState(() {
                      pageNumber++;
                    });
                    fetchUserPaymentDetails(
                      paymentMethod: selectedPaymentMethod,
                      paymentStatus: selectedPaymentStatus,
                      name: searchController.text,
                      pageNumber: pageNumber,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(child: Text('Error fetching payments. Please try again later.'));
    }

    if (filteredPayments.isEmpty) {
      return Center(child: Text('No payments found.'));
    }

    return ListView.builder(
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = filteredPayments[index];
        return UserpaymentDetailsBox(
          orderCode: payment.orderCode ?? '',
          paymentAmount: payment.amount ?? 0.0,
          paymentMethod: payment.paymentMethod ?? '',
          paymentStatus: payment.paymentStatus ?? '',
          name: payment.name ?? '',
        );
      },
    );
  }

Widget _buildSummaryBox() {
  if (selectedPaymentMethod == 'SD' && selectedPaymentStatus == 'Unpaid' && totalSDAmount > 0) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Unpaid SD Balance",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    searchController.text.isNotEmpty 
                        ? "for ${searchController.text}"
                        : "for all users",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "₱${totalSDAmount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
  return const SizedBox.shrink();
}
}