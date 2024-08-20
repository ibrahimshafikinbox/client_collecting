import 'package:client_app/Core/Helper/naviagation_helper.dart';
import 'package:client_app/Feature/Login/View/login_view.dart';
import 'package:client_app/Feature/Login/cubit/Login_Cubit.dart';
import 'package:client_app/Feature/customer_list/View/customer_list_view.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
import 'package:client_app/Feature/customer_notes/view/customer_notes_view.dart';
import 'package:client_app/Feature/resources/styles/app_text_style.dart';
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
                      Text('اسم المستخدم : ${usernameSnapshot.data}',
                          style: AppTextStyle.textStyleWhiteSemiBold19),
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
                      ListTile(
                          leading: Icon(Icons.update),
                          title: Text(' تحديث البيانات  '),
                          onTap: () async {
                            final cubit = GetCustomerCubit.get(context);

                            // Show a loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  content: Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 25),
                                      Text("يتم التحديث..."),
                                    ],
                                  ),
                                );
                              },
                            );

                            try {
                              await cubit.refreshApp();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('تم تحديث البيانات بنجاح!')),
                              );
                            } catch (error) {
                              Navigator.pop(
                                  context); // Close the loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('فشل في تحديث البيانات: $error')),
                              );
                            }

                            Navigator.pop(context); // Close the drawer
                          }

                          // onTap: () async {
                          //   final cubit = GetCustomerCubit.get(context);
                          //   await cubit.refreshApp();
                          //   Navigator.pop(context); // close drawer
                          // },
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
                          navigateAndFinish(context, const LoginView());
                        },
                      ),
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
