import 'package:final_canteen/admin-modules/pages/admin_home.dart';
import 'package:final_canteen/admin-modules/pages/removed_items_page.dart';
import 'package:final_canteen/employee_modules/pages/pages/settings_page.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:final_canteen/utils/custom_gmav_admin.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboard extends StatefulWidget {
  final int initialIndex;
  const AdminDashboard({super.key, required this.initialIndex});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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

    List<Widget> widgetOptions = <Widget>[
      AdminHome(navbarHeight: navbarHeight),
      RemovedItemsPage(navbarHeight: navbarHeight,),
      SettingsPage(),
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
                const NavigationRailDestination(
                  padding: EdgeInsets.all(10),
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.all(10),
                  icon: const Icon(Icons.delete), 
                  label: Container(
                    child: Text(
                      "Removed\nItems", 
                      textAlign: TextAlign.center,))
                  ),
                const NavigationRailDestination(
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
          ? CustomGnavAdmin(
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