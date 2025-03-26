import 'package:final_canteen/employee_modules/pages/pages/employee_home.dart';
import 'package:final_canteen/employee_modules/pages/pages/order_page.dart';
import 'package:final_canteen/employee_modules/pages/pages/settings_page.dart';
import 'package:final_canteen/employee_modules/pages/pages/user_management_page.dart';
import 'package:final_canteen/providers/user_provider.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:final_canteen/utils/custom_gnav_employee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeDashboard extends StatefulWidget {
  final int initialIndex;
  const EmployeeDashboard({super.key, required this.initialIndex});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _selectedIndex = 0;
  bool _isAuthChecking = false; 
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }
  
  
  Future<void> _checkAuthentication() async {
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      
      if (storedUserId != null && storedUserId.isNotEmpty) {
        
        if (userProvider.userId != storedUserId) {
          await userProvider.setUserId(storedUserId);
        }
        return; 
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      print("Error during authentication check: $e");
      if (!userProvider.isLoggedIn) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    }
  }

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
    double navbarHeight = 80;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
  
    List<Widget> widgetOptions = <Widget>[
      EmployeeHome(navbarHeight: navbarHeight),
      UserManagementPage(),
      OrderPage(navbarHeight: navbarHeight),
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
              destinations: const [
                NavigationRailDestination(
                  padding: EdgeInsets.all(10),
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.all(10),
                  icon: Icon(Icons.person),
                  label: Text('User'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.all(10),
                  icon: Icon(Icons.shopping_bag_outlined),
                  label: Text('Order'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.all(10),
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              backgroundColor: Colors.white, 
              selectedIconTheme: IconThemeData(
                color: const Color.fromARGB(255, 255, 255, 255), 
                size: 26, 
              ),
              unselectedIconTheme: IconThemeData(
                color: const Color.fromARGB(192, 226, 33, 19), 
                size: 24, 
              ),
              selectedLabelTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary, 
                fontSize: 14
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
          ? CustomGnavEmployee(
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