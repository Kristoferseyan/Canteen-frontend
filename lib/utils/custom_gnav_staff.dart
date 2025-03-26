// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomGnavStaff extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;
  final double navbarHeight;

  const CustomGnavStaff({
    super.key,
    required this.onTabChange,
    required this.selectedIndex, required this.navbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 700;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        boxShadow: [],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 200 : 10, 
            vertical: 8,
          ),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: isDesktop ? 2 : 4,
            activeColor: AppColors.secondary,
            iconSize: isDesktop ? 28 : 18, 
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 30 : 12, vertical: 12), 
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey[100]!,
            color: const Color.fromARGB(234, 201, 12, 12),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.add_card,
                text: 'Stock Management',),
              GButton(
                icon: Icons.attach_money, 
                text: 'Completed Orders',),
              GButton(
                icon: Icons.payment,
                text: 'User Payments',),
              GButton(
                icon: Icons.settings,
                text: 'Settings',
              ),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}
