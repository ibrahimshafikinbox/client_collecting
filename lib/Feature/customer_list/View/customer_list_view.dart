import 'package:client_app/Feature/customer_list/View/Selected_day_View.dart';
import 'package:client_app/Feature/customer_list/Widget/custom_app_bar.dart';
import 'package:client_app/Feature/customer_list/Widget/custom_drawer.dart';
import 'package:client_app/Feature/customer_list/Widget/customer_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_cubit.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_state.dart';

class CustomerListView extends StatefulWidget {
  @override
  State<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  int? _selectedDay;
  List<CustomerModel> _customers = [];
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    GetCustomerCubit.get(context).getCustomer();
  }

  Future<void> fetchData() async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      GetCustomerCubit.get(context).getCustomer();
    } else {
      setState(() {
        _isOffline = true;
      });
      await _loadCustomerDataFromSQLite();
    }
  }

  Future<bool> checkInternetConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  Future<void> _loadCustomerDataFromSQLite() async {
    List<CustomerModel> customers =
        await GetCustomerCubit.get(context).loadCustomerDataFromSQLite();
    setState(() {
      _customers = customers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetCustomerCubit(),
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          selectedDay: _selectedDay,
          onDateTap: () {
            _showCollectionDayPicker(context);
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isOffline
              ? CustomerPages(customers: _customers)
              : BlocBuilder<GetCustomerCubit, GetCustomerState>(
                  builder: (context, state) {
                    if (state is GetCustomerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetCustomerSuccess) {
                      _customers = state.customers;
                      return CustomerPages(customers: _customers);
                    } else if (state is GetCustomerError) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else {
                      return Center(
                        child: TextButton(
                          onPressed: () {
                            GetCustomerCubit.get(context).getCustomer();
                          },
                          child: const Icon(Icons.refresh),
                        ),
                      );
                    }
                  },
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
      // Filter customers by selected day
      List<CustomerModel> filteredCustomers = _customers
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
