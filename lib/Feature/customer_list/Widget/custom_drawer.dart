import 'package:client_app/Core/Helper/naviagation_helper.dart';
import 'package:client_app/Feature/Login/View/login_view.dart';
import 'package:client_app/Feature/Login/cubit/Login_Cubit.dart';
import 'package:client_app/Feature/customer_list/View/customer_list_view.dart';
import 'package:client_app/Feature/customer_notes/view/customer_notes_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  // Function to get the username from SharedPreferences
  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'User';
  }

  // Function to get the subtraction value from SharedPreferences
  Future<double> getSubtractionValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('subtractionValue') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUsername(),
      builder: (context, usernameSnapshot) {
        if (usernameSnapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while fetching data
          return Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (usernameSnapshot.hasError) {
          // Show error message if there is an error
          return Drawer(
            child: Center(child: Text('Error: ${usernameSnapshot.error}')),
          );
        } else {
          // Display drawer once the username is fetched
          return Drawer(
            child: Column(
              children: [
                // Drawer Header
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F1451),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'اسم المستخدم : ${usernameSnapshot.data}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Drawer Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text('قائمه العملاء'),
                        onTap: () {
                          navigateAndFinish(context, CustomerListView());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.report_outlined),
                        title: Text('ملاحظات العملاء'),
                        onTap: () {
                          navigateTo(context, NotesPage());
                        },
                      ),
                      FutureBuilder<double>(
                        future: getSubtractionValue(),
                        builder: (context, valueSnapshot) {
                          if (valueSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              title: Text('Loading...'),
                            );
                          } else if (valueSnapshot.hasError) {
                            return ListTile(
                              title: Text('Error loading value'),
                            );
                          } else {
                            return ListTile(
                              title: Text(
                                  'قيمه الدفع الشهرى : ${valueSnapshot.data}'),
                            );
                          }
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('تسجيل الخروج'),
                        onTap: () async {
                          final cubit = LoginCubit.get(context);
                          await cubit.logOutUser(); // Trigger logout
                          navigateAndFinish(context, LoginView());
                        },
                      ),
                      // ListTile to display subtraction value
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
