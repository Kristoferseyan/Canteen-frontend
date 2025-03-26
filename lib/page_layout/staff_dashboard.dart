// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:final_canteen/employee_modules/pages/pages/settings_page.dart';
import 'package:final_canteen/staff_modules/pages/completed_order_pages.dart';
import 'package:final_canteen/staff_modules/pages/staff_home.dart';
import 'package:final_canteen/staff_modules/pages/stock_mngmnt.dart';
import 'package:final_canteen/staff_modules/pages/user_payments_page.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:final_canteen/utils/custom_gnav_staff.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _selectedIndex = 0;


  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 700;
    double navbarHeight = 40;

    List<Widget> widgetOptions = <Widget>[
      const StaffHome(navbarHeight: 40),
      const StockMngmnt(navbarHeight: 40),
      const CompletedOrderPages(navbarHeight: 40),
      const UserPaymentsPage(navbarHeight: 40),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onDoubleTap: () {
                  _launchInBrowser(Uri.parse('https://seanportfolio-57516.web.app/'));
                  },
                  child: Image.asset('assets/images/brigadalogo.png', scale: 3),
                ),
              ),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: [
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 10.0), 
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  icon: Icon(Icons.list_alt),
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Stock',
                      textAlign: TextAlign.center,)),
                ),
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  icon: Icon(Icons.check),
                  label: Container(
                    alignment: Alignment.center, 
                    child: Text(
                      'Completed\nOrders',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  icon: Icon(Icons.payment),
                  label: Text('Payments'),
                ),
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              backgroundColor: Colors.white,
              selectedIconTheme: IconThemeData(
                color: const Color.fromARGB(255, 255, 255, 255),
                size: 28,
              ),
              unselectedIconTheme: IconThemeData(
                color: const Color.fromARGB(192, 226, 33, 19),
                size: 24,
              ),
              selectedLabelTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
                fontSize: 14,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: const Color.fromARGB(192, 226, 33, 19),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              labelType: NavigationRailLabelType.all,
              groupAlignment: 0.0,
              indicatorColor: AppColors.primary,
            ),
          Expanded(
            child: Center(
              child: widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? CustomGnavStaff(
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedIndex: _selectedIndex,
              navbarHeight: navbarHeight,
            )
          : null,
    );
  }
}