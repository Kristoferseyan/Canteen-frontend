
import 'package:final_canteen/employee_modules/pages/pages/order_page.dart';
import 'package:final_canteen/employee_modules/pages/widgets/cart_screen.dart';
import 'package:final_canteen/page_layout/admin_dashboard.dart';
import 'package:final_canteen/page_layout/employee_dashboard.dart';
import 'package:final_canteen/page_layout/staff_dashboard.dart';
import 'package:final_canteen/landing_page.dart';
import 'package:final_canteen/auth/login_page.dart';
import 'package:final_canteen/auth/reg_page.dart';
import 'package:final_canteen/providers/cart_provider.dart';
import 'package:final_canteen/providers/order_provider.dart';
import 'package:final_canteen/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  
runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
      routes: {
        '/landingpage': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/reg': (context) => const RegPage(),
        '/employee_dashboard': (context) => const EmployeeDashboard(initialIndex: 0,),
        "/cart": (context) => const CartScreen(),
        '/staff_dashboard': (context) => const StaffDashboard(),
        '/order_page': (context) => const OrderPage(navbarHeight: 0,),
        '/admin_dashboard': (context) => const AdminDashboard(initialIndex: 0,)
      },

    );
  }
}
