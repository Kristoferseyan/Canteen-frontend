// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 600; 

          return Container(
            decoration: BoxDecoration(
              color: Colors.white
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/brigadalogo.png',
                    height: isDesktop ? 450 : 250, 
                  ),


                  SizedBox(height: isDesktop ? 0 : 60),
//--------------------LOGIN-BUTTON--------------------//
                  SizedBox(
                    height: 50,
                    width: isDesktop ? 280 : 220, 
                    child: ElevatedButton(
                      onPressed: () { Navigator.pushNamed(context, '/login'); }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), 
                        ),
                        shadowColor: Colors.black, 
                        elevation: 5, 
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood, color: Colors.white, size: isDesktop ? 28 : 24), 
                          SizedBox(width: 8),
                          Text(
                            "Login", 
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: isDesktop ? 20 : 18, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

//--------------------REGISTER-BUTTON--------------------//
                  SizedBox(
                    height: 50,
                    width: isDesktop ? 280 : 220, 
                    child: ElevatedButton(
                      onPressed: () { Navigator.pushNamed(context, '/reg'); }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.black,
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, color: Colors.white, size: isDesktop ? 28 : 24), 
                          SizedBox(width: 8),
                          Text(
                            "Register", 
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
