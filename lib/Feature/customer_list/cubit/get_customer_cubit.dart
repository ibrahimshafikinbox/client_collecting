import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client_app/Core/Helper/DatabaseHelper.dart';
import 'package:client_app/Core/Helper/constants.dart';
import 'package:client_app/Feature/customer_list/cubit/get_customer_state.dart';
import 'package:client_app/Feature/customer_list/customer_model/address.dart';
import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
import 'package:client_app/Feature/customer_list/records_model/records_model.dart';

class GetCustomerCubit extends Cubit<GetCustomerState> {
  final Dio dio = Dio();
  List<CustomerModel> customerList = [];
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<CustomerModel> filteredCustomers = [];
  RecordsModel? recordsModel;
  String? _token; // Store token as a member variable

  // GetCustomerCubit() : super(GetCustomerInitial());
  GetCustomerCubit() : super(GetCustomerInitial()) {
    _initializeToken(); // Initialize token
    getCustomer();
  }

  static GetCustomerCubit get(context) => BlocProvider.of(context);
  Future<void> _initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token == null) {
      print("Token not found in SharedPreferences.");
    } else {
      print("Token initialized: $_token");
    }
  }

  Future<void> filterByCollectionDay(int? selectedDay) async {
    if (selectedDay == null) {
      emit(GetCustomerSuccess(customerList));
    } else {
      filteredCustomers = customerList
          .where((customer) => customer.collectDay == selectedDay)
          .toList();
      emit(GetCustomerSuccess(filteredCustomers));
      print(
          "🚀🚀Filtered customers by day $selectedDay: ${filteredCustomers.length}");
    }
  }

  Future<List<CustomerModel>> getCustomer() async {
    emit(GetCustomerLoading());
    try {
      print("🚀Fetching customers...🚀");

      int? savedVersion = await getSavedVersion();
      int apiVersion = await getAPIVersion();

      if (savedVersion != null && savedVersion == apiVersion) {
        print("🚀Version has not changed. Loading data from SQLite...🚀");

        List<CustomerModel> customerList = await loadCustomerDataFromSQLite();
        emit(GetCustomerSuccess(customerList));
        print("🚀Loaded ${customerList.length} customers from SQLite.🚀");
        return customerList; // Return the loaded list
      } else {
        print("🚀Version changed or not found. Fetching data from API...🚀");

        if (await isConnected()) {
          final Response response = await dio.get(
            '${Constants.baseUrl}${Constants.customers}',
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Accept-Language': 'en',
                "Authorization": "Token $_token",
              },
            ),
          );

          List<dynamic> dataList = response.data;
          List<CustomerModel> customerList =
              dataList.map((item) => CustomerModel.fromJson(item)).toList();

          await saveCustomerDataToSQLite(customerList);

          List<Map<String, dynamic>> amounts = await getCustomerAmount();
          List<CustomerModel> combinedList =
              combineCustomerDataWithAmounts(customerList, amounts);

          await saveCustomerDataToSQLite(
              combinedList); // Save combined list with amounts

          // Save the new version to local storage
          await saveVersion(apiVersion);

          emit(GetCustomerSuccess(combinedList));
          print(
              "🚀Fetched and combined ${combinedList.length} customers from API.🚀");
          return combinedList; // Return the combined list
        } else {
          print("🚀No internet connection. Loading data from SQLite...🚀");

          List<CustomerModel> customerList = await loadCustomerDataFromSQLite();
          emit(GetCustomerSuccess(customerList));
          print("🚀Loaded ${customerList.length} customers from SQLite.🚀");
          return customerList; // Return the loaded list
        }
      }
    } catch (error) {
      emit(GetCustomerError("🚀Failed to load customers: $error 🚀"));
      print("🚀Error loading customers: $error🚀");
      return []; // Return an empty list in case of error
    }
  }

  Future<void> saveCustomerDataToSQLite(List<CustomerModel> customers) async {
    await databaseHelper.clearCustomers();
    for (var customer in customers) {
      await databaseHelper.insertCustomer({
        'id': customer.id,
        'name': customer.name,
        'collect_day': customer.collectDay,
        'nick_name': customer.nickName,
        'phone': customer.phone,
        'description': customer.description,
        'isActive': customer.isActive == true ? 1 : 0,
        'address': jsonEncode(customer.address?.toJson()), // Serialize address
        'amount': customer.amount, // Add amount field
      });
    }
    print("Saved ${customers.length} customers to SQLite.");
  }

  Future<List<CustomerModel>> loadCustomerDataFromSQLite() async {
    final data = await databaseHelper.getCustomers();
    List<CustomerModel> customers = [];
    for (var item in data) {
      var addressMap = jsonDecode(item['address']) as Map<String, dynamic>;
      var customer = CustomerModel(
        id: item['id'],
        name: item['name'],
        collectDay: item['collect_day'],
        nickName: item['nick_name'],
        phone: item['phone'],
        description: item['description'],
        isActive: item['isActive'] == 1,
        address: Address.fromJson(addressMap),
        amount: item['amount']?.toDouble(), // Retrieve amount
      );
      customers.add(customer);
    }
    return customers;
  }

  Future<bool> isConnected() async {
    bool connected = await InternetConnectionChecker().hasConnection;
    print("🚀Internet connected: $connected");
    return connected;
  }

  Future<int> getAPIVersion() async {
    final Response response = await dio.get(
      '${Constants.baseUrl}${Constants.version}',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en', "Authorization": "Token $_token",

          // "Authorization": "Token 55c754cbcb7b0a0631b13a44d0641514d5171175",
        },
      ),
    );
    print(response.data['version']);
    return response.data['version'];
  }

  Future<int?> getSavedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('version');
  }

  Future<void> saveVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('version', version);
  }

  Future<List<Map<String, dynamic>>> getCustomerAmount() async {
    try {
      final Response response = await dio.get(
        '${Constants.baseUrl}${Constants.amount}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Accept-Language': 'en',
            "Authorization": "Token $_token",
          },
        ),
      );

      List<dynamic> dataList = response.data;
      List<Map<String, dynamic>> amounts =
          List<Map<String, dynamic>>.from(dataList);

      print("🚀Fetched ${amounts.length} customer amounts from API.🚀");
      print("Amounts List: $amounts");
      return amounts;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  List<CustomerModel> combineCustomerDataWithAmounts(
      List<CustomerModel> customers, List<Map<String, dynamic>> amounts) {
    // Create a map for quick lookup of amounts by customer id
    Map<int, double> amountMap = {
      for (var amount in amounts)
        (amount['customer'] ?? 0): (amount['amount'] ?? 0.0).toDouble()
    };

    // Merge customer data with amounts
    return customers.map((customer) {
      double? amount = amountMap[customer.id];
      return CustomerModel(
        id: customer.id,
        name: customer.name,
        collectDay: customer.collectDay,
        nickName: customer.nickName,
        phone: customer.phone,
        description: customer.description,
        isActive: customer.isActive,
        address: customer.address,
        amount: amount, // Add amount to customer model
      );
    }).toList();
  }

  Future<RecordsModel> getRecords() async {
    emit(GetRecordsLoading());
    try {
      final response = await dio.get(
        '${Constants.baseUrl}${Constants.record}',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Accept-Language': 'en',
            "Authorization": "Token $_token",
          },
        ),
      );

      print("Response data: ${response.data}");

      // Check if response data is a map
      if (response.data is Map<String, dynamic>) {
        final recordsModel = RecordsModel.fromJson(response.data);
        emit(GetRecordsSuccess(recordsModel));
        return recordsModel;
      } else {
        final errorMessage = "Unexpected response format";
        print(errorMessage);
        emit(GetRecordsError(errorMessage));
        throw Exception(errorMessage);
      }
    } catch (e) {
      emit(GetRecordsError(e.toString()));
      print("Error in getRecords: $e"); // Print the error for debugging
      rethrow; // Re-throw the error to be handled by FutureBuilder
    }
  }
}
