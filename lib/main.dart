import 'package:client_app/Core/Helper/DatabaseHelper.dart';
import 'package:client_app/Feature/Login/View/login_view.dart';
import 'package:client_app/Feature/Login/cubit/Login_Cubit.dart';
import 'package:client_app/Feature/customer_list/View/customer_list_view.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
import 'package:client_app/Feature/customer_notes/cubit/custoemr_notes_cubit.dart';
import 'package:client_app/Feature/payment/cubit/paymant_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SQLite database
  final databaseHelper = DatabaseHelper();

  // Check if token is stored in SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print(token);

  runApp(MyApp(
      initialView: token != null ? CustomerListView() : const LoginView()));
}

class MyApp extends StatelessWidget {
  final Widget initialView;

  const MyApp({super.key, required this.initialView});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => GetCustomerCubit()),
        BlocProvider(create: (context) => PaymentCubit()),
        BlocProvider(create: (context) => CustomerNotesCubit()),
      ],
      child: MaterialApp(
        supportedLocales: const [
          Locale('ar'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        home: initialView,
      ),
    );
  }
}
