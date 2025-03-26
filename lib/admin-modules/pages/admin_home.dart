// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:final_canteen/services/role_service.dart';
import 'package:final_canteen/model/user_role_model.dart';
import 'package:final_canteen/services/user_services.dart';
import 'package:final_canteen/utils/colors.dart';

class AdminHome extends StatefulWidget {
  final double navbarHeight;
  const AdminHome({super.key, required this.navbarHeight});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final UserApiServices userApiServices = UserApiServices();
  final RoleApiService roleApiService = RoleApiService();

  List<Map<String, String>> roles = [];
  List<UserRole> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
    loadRoles();
  }

  void loadUsers() async {
    final user = await userApiServices.fetchUsersRole();
    if (mounted) {
      setState(() {
        users = user;
      });
    }
  }

  void loadRoles() async {
    try {
      var roleData = await roleApiService.fetchRoles();
      if (mounted) {
        setState(() {
          roles = roleData.data
              .map((role) => {
                    'id': role.id!,
                    'roleName': role.roleName,
                  })
              .toList();
        });
      }
    } catch (e) {
      print("Failed to load roles: $e");
    }
  }

  void updateUserRole(UserRole user, String roleId) async {
    bool success = await userApiServices.updateUserRole(user.id, roleId);
    if (success) {
      setState(() {
        user.roleName =
            roles.firstWhere((role) => role['id'] == roleId)['roleName']!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User role updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update role')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 700;
    double availableHeight =
        MediaQuery.of(context).size.height - widget.navbarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                spreadRadius: 2,
                color:isDesktop ? const Color.fromARGB(64, 0, 0, 0) : const Color.fromARGB(0, 255, 255, 255),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          height:isDesktop ? availableHeight * 1.03 : availableHeight * 1,
          width: width,
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.manage_accounts,
                      size: 40,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "User Role Management",
                      style: TextStyle(
                          fontSize: isDesktop ? 30 : 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Container(
                width: width * 0.90,
                height:isDesktop ? availableHeight * 0.8 : availableHeight * 0.801,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border.all(
                  //   color:isDesktop ? const Color.fromARGB(52, 0, 0, 0) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: users.isEmpty
                    ? Center(
                        child: Text('No users found',
                            style: TextStyle(fontSize: 18)),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 3 : 1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 8,
                            childAspectRatio:isDesktop ? 1.7 : 1.4,
                          ),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            UserRole user = users[index];

                            return Container(
                              child: Card(
                                color: Colors.white,
                                margin: EdgeInsets.all(10.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 6.0,
                                shadowColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person, color: AppColors.primary,),
                                          SizedBox(width: 8),
                                          Text(
                                            'Name: ${user.firstName} ${user.lastName}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.face, color: const Color.fromARGB(126, 226, 33, 19), size: 22),
                                          SizedBox(width: 8),
                                          Text(
                                            "Username: ${user.username}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.supervisor_account, color: AppColors.primary,),
                                          SizedBox(width: 8),
                                          Text(
                                            user.roleName[0].toUpperCase() + user.roleName.substring(1),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textBlack,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      DropdownButton<String>(
                                        value: user.roleId,
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        iconEnabledColor: AppColors.secondary,
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 179, 33, 33),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        underline: Container(
                                          height: 2,
                                          color: AppColors.primary,
                                        ),
                                        items: roles.map((role) {
                                          return DropdownMenuItem<String>(
                                            value: role['id'],
                                            child: Text(
                                              role['roleName']![0].toUpperCase() + role['roleName']!.substring(1),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            updateUserRole(user, newValue);
                                            setState(() {
                                              user.roleId = newValue;
                                            });
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
