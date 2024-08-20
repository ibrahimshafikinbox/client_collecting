// import 'package:client_app/Core/Helper/snack_bar_helper.dart';
// import 'package:client_app/Feature/customer_list/View/Selected_day_View.dart';
// import 'package:client_app/Feature/payment/cubit/paymant_cubit.dart';
// import 'package:client_app/Feature/payment/cubit/payment_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
// import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
// import 'package:client_app/Feature/customer_list/Widget/custom_app_bar.dart';
// import 'package:client_app/Feature/customer_list/Widget/custom_drawer.dart';
// import 'package:client_app/Feature/customer_list/Widget/customer_pages.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';

// class CustomerListView extends StatefulWidget {
//   @override
//   State<CustomerListView> createState() => _CustomerListViewState();
// }

// class _CustomerListViewState extends State<CustomerListView> {
//   int? _selectedDay;
//   Future<List<CustomerModel>>? _customerFuture;
//   bool _isOffline = false;
//   List<CustomerModel> _customers = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     bool isConnected = await checkInternetConnection();
//     if (isConnected) {
//       setState(() {
//         _customerFuture = GetCustomerCubit.get(context).getCustomer();
//       });
//       showToast(text: "متصل بالانترنت ً", state: ToastStates.SUCCESS);
//     } else {
//       setState(() {
//         _isOffline = true;
//         _customerFuture = _loadCustomerDataFromSQLite();
//       });
//       showToast(text: "غير متصل بالانترنت ً", state: ToastStates.SUCCESS);
//     }
//   }

//   Future<bool> checkInternetConnection() async {
//     return await InternetConnectionChecker().hasConnection;
//   }

//   Future<List<CustomerModel>> _loadCustomerDataFromSQLite() async {
//     List<CustomerModel> customers =
//         await GetCustomerCubit.get(context).loadCustomerDataFromSQLite();
//     setState(() {
//       _customers = customers;
//     });
//     return _customers;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => GetCustomerCubit(),
//       child: Scaffold(
//         drawer: CustomDrawer(),
//         appBar: CustomAppBar(
//           selectedDay: _selectedDay,
//           onDateTap: () {
//             _showCollectionDayPicker(context);
//           },
//         ),
//         body: BlocListener<PaymentCubit, PaymentStates>(
//           listener: (context, state) {
//             if (state is PaymentSuccess) {
//               fetchData();
//             }
//           },
//           child: FutureBuilder<List<CustomerModel>>(
//             future: _customerFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               } else if (snapshot.hasData) {
//                 final customers = snapshot.data!;
//                 return CustomerPages(customers: customers);
//               } else {
//                 return Center(
//                   child: TextButton(
//                     onPressed: fetchData,
//                     child: const Icon(Icons.refresh),
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _showCollectionDayPicker(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(DateTime.now().year),
//       lastDate: DateTime(DateTime.now().year, 12, 28), // Month with 28 days
//       locale: Locale('ar', 'AE'), // Arabic locale for the date picker
//     );
//     if (picked != null) {
//       // Access the list of customers to filter
//       List<CustomerModel> customers = await _customerFuture ?? [];
//       List<CustomerModel> filteredCustomers = customers
//           .where((customer) => customer.collectDay == picked.day)
//           .toList();

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SelectedDayCustomersPage(
//             selectedDay: picked.day,
//             selectedCustomers: filteredCustomers,
//           ),
//         ),
//       );
//     }
//   }
// }
import 'package:client_app/Core/Helper/snack_bar_helper.dart';
import 'package:client_app/Feature/customer_list/View/Selected_day_View.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_state.dart';
import 'package:client_app/Feature/payment/cubit/paymant_cubit.dart';
import 'package:client_app/Feature/payment/cubit/payment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
import 'package:client_app/Feature/customer_list/Widget/custom_app_bar.dart';
import 'package:client_app/Feature/customer_list/Widget/custom_drawer.dart';
import 'package:client_app/Feature/customer_list/Widget/customer_pages.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CustomerListView extends StatefulWidget {
  @override
  State<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  int? _selectedDay;
  Future<List<CustomerModel>>? _customerFuture;
  bool _isOffline = false;
  List<CustomerModel> _customers = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      setState(() {
        _customerFuture = GetCustomerCubit.get(context).getCustomer();
      });
      showToast(text: "متصل بالانترنت ً", state: ToastStates.SUCCESS);
    } else {
      setState(() {
        _isOffline = true;
        _customerFuture = _loadCustomerDataFromSQLite();
      });
      showToast(text: "غير متصل بالانترنت ً", state: ToastStates.SUCCESS);
    }
  }

  Future<bool> checkInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  Future<List<CustomerModel>> _loadCustomerDataFromSQLite() async {
    List<CustomerModel> customers =
        await GetCustomerCubit.get(context).loadCustomerDataFromSQLite();
    setState(() {
      _customers = customers;
    });
    return _customers;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetCustomerCubit()
        ..getCustomer(), // Fetch customer data on initialization
      child: BlocListener<GetCustomerCubit, GetCustomerState>(
        listener: (context, state) {
          if (state is NotaAouthorized) {
            // Show a dialog or error message
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('خطا فى التوكين'),
                  content: Text('انتهت جلسه الرمز .. سجل دخولك مره اخرى '),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Optionally navigate to the login screen
                        // Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text('حسنا '),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Scaffold(
          drawer: CustomDrawer(),
          appBar: CustomAppBar(
            selectedDay: _selectedDay,
            onDateTap: () {
              _showCollectionDayPicker(context);
            },
          ),
          body: BlocListener<PaymentCubit, PaymentStates>(
            listener: (context, state) {
              if (state is PaymentSuccess) {
                fetchData();
              }
            },
            child: FutureBuilder<List<CustomerModel>>(
              future: _customerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final customers = snapshot.data!;
                  return CustomerPages(customers: customers);
                } else {
                  return Center(
                    child: TextButton(
                      onPressed: fetchData,
                      child: const Icon(Icons.refresh),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCollectionDayPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year, 12, 28), // Month with 28 days
      locale: Locale('ar', 'AE'), // Arabic locale for the date picker
    );
    if (picked != null) {
      // Access the list of customers to filter
      List<CustomerModel> customers = await _customerFuture ?? [];
      List<CustomerModel> filteredCustomers = customers
          .where((customer) => customer.collectDay == picked.day)
          .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectedDayCustomersPage(
            selectedDay: picked.day,
            selectedCustomers: filteredCustomers,
          ),
        ),
      );
    }
  }
}
