// import 'dart:convert';
// import 'package:client_app/Core/Helper/constants.dart';
// import 'package:client_app/Feature/customer_list/customer_model/address.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:client_app/Feature/payment/cubit/payment_state.dart';
// import 'package:client_app/Core/Helper/DatabaseHelper.dart';
// import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';

// class PaymentCubit extends Cubit<PaymentStates> {
//   final Dio _dio = Dio();
//   final DatabaseHelper databaseHelper =
//       DatabaseHelper(); // Instantiate DatabaseHelper
//   List<Map<String, dynamic>> paymentQueue = [];
//   late InternetConnectionChecker connectionChecker;
//   String? _token; // Store token as a member variable

//   PaymentCubit() : super(PaymentInitial()) {
//     _initializeToken(); // Initialize token

//     connectionChecker = InternetConnectionChecker();
//     monitorConnection();
//   }

//   static PaymentCubit get(context) => BlocProvider.of(context);
//   Future<void> _initializeToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     if (_token == null) {
//       print("Token not found in SharedPreferences.");
//     } else {
//       print("Token initialized: $_token");
//     }
//   }

//   Future<void> postPayment(id, bool? isRefund) async {
//     await fetchValueToSubtract(); // Fetch and store the value to be subtracted
//     final paymentData = {
//       'customer_id': id,
//       'isrefund': isRefund,
//     };

//     print("Attempting to post payment: $paymentData");

//     if (await isConnected()) {
//       print("Internet is connected, sending payment.");

//       await sendPayment(paymentData);
//     } else {
//       print("Internet is not connected, queuing payment.");
//       queuePayment(paymentData);
//     }
//   }

//   Future<void> sendPayment(Map<String, dynamic> paymentData) async {
//     emit(PaymentLoading());

//     try {
//       print("Sending payment: $paymentData");
//       await _dio.post(
//         "${Constants.baseUrl}${Constants.postPayment}",
//         data: paymentData,
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       // Subtract value from customer's amount in the local database
//       final prefs = await SharedPreferences.getInstance();
//       final subtractionValue = prefs.getDouble('subtractionValue') ?? 0.0;

//       print(
//           "Subtraction value retrieved from SharedPreferences: $subtractionValue");

//       // Fetch the current customer data
//       final customerId = paymentData['customer_id'];
//       final customerData = await databaseHelper.getCustomerById(customerId);

//       if (customerData != null) {
//         // Current amount for the customer
//         final currentAmount = customerData['amount'] ?? 0.0;
//         print("Current amount for customer ID $customerId: $currentAmount");

//         // Calculate the new amount
//         final newAmount = currentAmount - subtractionValue;
//         print("New calculated amount for customer ID $customerId: $newAmount");

//         // Update the customer's amount in the local database
//         await updateCustomerAmount(customerId, newAmount);

//         // Fetch updated customer data
//         List<CustomerModel> updatedCustomerList = await fetchUpdatedCustomers();

//         // Emit updated state with the new customer data
//         emit(PaymentSuccess(updatedCustomerList));

//         debugPrint(
//             "Payment sent successfully and amount updated: $paymentData");
//         // showToast(
//         //     text: "تم الدفع بنجاح وتم تحديث المبلغ",
//         //     state: ToastStates.SUCCESS);
//       } else {
//         print("Customer with ID $customerId not found.");
//         emit(PaymentFailure());
//         // showToast(text: "العميل غير موجود", state: ToastStates.ERROR);
//       }
//     } catch (e) {
//       print("Failed to send payment: $e");
//       queuePayment(paymentData);

//       // Emit failure state
//       emit(PaymentFailure());
//     }
//   }

//   Future<void> fetchValueToSubtract() async {
//     try {
//       final response = await _dio.get(
//         "https://momen-three.vercel.app/customers/get_main_value/",
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       // Assuming the response contains the value to subtract
//       final valueToSubtract = response.data['value']?.toDouble() ?? 0.0;

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('subtractionValue', valueToSubtract);

//       print("Fetched and stored subtraction value: $valueToSubtract");
//     } catch (e) {
//       print("Failed to fetch value: $e");
//     }
//   }

//   void queuePayment(Map<String, dynamic> paymentData) {
//     paymentQueue.add(paymentData);
//     emit(Paymentaddeddtoqueuee());
//     print("Payment added to queue: $paymentData");
//     // showToast(
//     //     text: "تمت إضافة الدفع إلى قائمة الانتظار", // Arabic message
//     //     state: ToastStates.WARNING);
//   }

//   Future<bool> isConnected() async {
//     bool connectionStatus = await connectionChecker.hasConnection;
//     print("Connection status: $connectionStatus");
//     // showToast(
//     //     text: "حالة الاتصال: $connectionStatus", state: ToastStates.WARNING);

//     return connectionStatus;
//   }

//   void monitorConnection() {
//     connectionChecker.onStatusChange.listen((status) {
//       print("Internet connection status changed: $status");
//       if (status == InternetConnectionStatus.connected) {
//         print("Processing queued payments.");
//         processQueue();
//       }
//     });
//   }

//   void processQueue() {
//     if (paymentQueue.isNotEmpty) {
//       print("Processing payment queue: $paymentQueue");
//       for (var payment in paymentQueue) {
//         sendPayment(payment);
//       }
//       paymentQueue.clear();
//       print("Payment queue cleared.");
//     } else {
//       print("قائمة الانتظار فارغة.");
//     }
//   }

//   Future<void> updateCustomerAmount(int customerId, double newAmount) async {
//     // Update the customer's amount in the local database
//     await databaseHelper.updateCustomerAmount(customerId, newAmount);
//   }

//   Future<List<CustomerModel>> fetchUpdatedCustomers() async {
//     final data = await databaseHelper.getCustomers();
//     List<CustomerModel> customers = [];
//     for (var item in data) {
//       var addressMap = jsonDecode(item['address']) as Map<String, dynamic>;
//       var customer = CustomerModel(
//         id: item['id'],
//         name: item['name'],
//         collectDay: item['collect_day'],
//         nickName: item['nick_name'],
//         phone: item['phone'],
//         description: item['description'],
//         isActive: item['isActive'] == 1,
//         address: Address.fromJson(addressMap),
//         amount: item['amount']?.toDouble(), // Retrieve amount
//       );
//       customers.add(customer);
//     }
//     return customers;
//   }
// }
// import 'dart:convert';
// import 'package:client_app/Core/Helper/constants.dart';
// import 'package:client_app/Core/Helper/snack_bar_helper.dart';
// import 'package:client_app/Feature/customer_list/customer_model/address.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:client_app/Feature/payment/cubit/payment_state.dart';
// import 'package:client_app/Core/Helper/DatabaseHelper.dart';
// import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';

// class PaymentCubit extends Cubit<PaymentStates> {
//   final Dio _dio = Dio();
//   final DatabaseHelper databaseHelper =
//       DatabaseHelper(); // Instantiate DatabaseHelper
//   List<Map<String, dynamic>> paymentQueue = [];
//   late InternetConnectionChecker connectionChecker;
//   String? _token; // Store token as a member variable

//   PaymentCubit() : super(PaymentInitial()) {
//     connectionChecker = InternetConnectionChecker();
//     monitorConnection();
//     _initializeToken(); // Initialize token
//   }

//   static PaymentCubit get(context) => BlocProvider.of(context);
//   Future<void> _initializeToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     if (_token == null) {
//       print("Token not found in SharedPreferences.");
//     } else {
//       print("Token initialized: $_token");
//     }
//   }

//   Future<void> postPayment(id, bool? isRefund) async {
//     await fetchValueToSubtract(); // Fetch and store the value to be subtracted
//     final paymentData = {
//       'customer_id': id,
//       'isrefund': isRefund,
//     };

//     print("Attempting to post payment: $paymentData");

//     if (await isConnected()) {
//       print("Internet is connected, sending payment.");

//       await sendPayment(paymentData);
//     } else {
//       print("Internet is not connected, queuing payment.");
//       queuePayment(paymentData);
//     }
//   }

//   Future<void> sendPayment(Map<String, dynamic> paymentData) async {
//     emit(PaymentLoading());

//     try {
//       print("Sending payment: $paymentData");
//       await _dio.post(
//         "${Constants.baseUrl}${Constants.postPayment}",
//         data: paymentData,
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       // Subtract value from customer's amount in the local database
//       final prefs = await SharedPreferences.getInstance();
//       final subtractionValue = prefs.getDouble('subtractionValue') ?? 0.0;

//       print(
//           "Subtraction value retrieved from SharedPreferences: $subtractionValue");

//       // Fetch the current customer data
//       final customerId = paymentData['customer_id'];
//       final customerData = await databaseHelper.getCustomerById(customerId);

//       if (customerData != null) {
//         // Current amount for the customer
//         final currentAmount = customerData['amount'] ?? 0.0;
//         print("Current amount for customer ID $customerId: $currentAmount");

//         // Calculate the new amount
//         final newAmount = currentAmount - subtractionValue;
//         print("New calculated amount for customer ID $customerId: $newAmount");

//         // Update the customer's amount in the local database
//         await updateCustomerAmount(customerId, newAmount);
//         emit(UpdatedCustomerData());

//         // Fetch updated customer data
//         List<CustomerModel> updatedCustomerList = await fetchUpdatedCustomers();

//         // Emit updated state with the new customer data
//         emit(PaymentSuccess(updatedCustomerList));

//         debugPrint(
//             "Payment sent successfully and amount updated: $paymentData");
//         // showToast(
//         //     text: "تم الدفع بنجاح وتم تحديث المبلغ",
//         //     state: ToastStates.SUCCESS);
//       } else {
//         print("Customer with ID $customerId not found.");
//         emit(PaymentFailure());
//         // showToast(text: "العميل غير موجود", state: ToastStates.ERROR);
//       }
//     } catch (e) {
//       print("Failed to send payment: $e");
//       queuePayment(paymentData);

//       // Emit failure state
//       emit(PaymentFailure());
//     }
//   }

//   Future<void> fetchValueToSubtract() async {
//     try {
//       final response = await _dio.get(
//         "https://momen-three.vercel.app/customers/get_main_value/",
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       // Assuming the response contains the value to subtract
//       final valueToSubtract = response.data['value']?.toDouble() ?? 0.0;

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('subtractionValue', valueToSubtract);

//       print("Fetched and stored subtraction value: $valueToSubtract");
//     } catch (e) {
//       print("Failed to fetch value: $e");
//     }
//   }

//   void queuePayment(Map<String, dynamic> paymentData) {
//     paymentQueue.add(paymentData);
//     emit(Paymentaddeddtoqueuee());
//     print("Payment added to queue: $paymentData");
//     showToast(
//         text: "تمت إضافة الدفع إلى قائمة الانتظار", // Arabic message
//         state: ToastStates.WARNING);
//   }

//   Future<bool> isConnected() async {
//     bool connectionStatus = await connectionChecker.hasConnection;
//     print("Connection status: $connectionStatus");
//     showToast(
//         text: "حالة الاتصال: $connectionStatus", state: ToastStates.WARNING);

//     return connectionStatus;
//   }

//   void monitorConnection() {
//     connectionChecker.onStatusChange.listen((status) {
//       print("Internet connection status changed: $status");
//       if (status == InternetConnectionStatus.connected) {
//         print("Processing queued payments.");
//         processQueue();
//       }
//     });
//   }

//   void processQueue() {
//     if (paymentQueue.isNotEmpty) {
//       print("Processing payment queue: $paymentQueue");
//       for (var payment in paymentQueue) {
//         sendPayment(payment);
//       }
//       paymentQueue.clear();
//       print("Payment queue cleared.");
//     } else {
//       print("قائمة الانتظار فارغة.");
//     }
//   }

//   Future<void> updateCustomerAmount(int customerId, double newAmount) async {
//     // Update the customer's amount in the local database
//     await databaseHelper.updateCustomerAmount(customerId, newAmount);
//   }

//   Future<List<CustomerModel>> fetchUpdatedCustomers() async {
//     final data = await databaseHelper.getCustomers();
//     List<CustomerModel> customers = [];
//     for (var item in data) {
//       var addressMap = jsonDecode(item['address']) as Map<String, dynamic>;
//       var customer = CustomerModel(
//         id: item['id'],
//         name: item['name'],
//         collectDay: item['collect_day'],
//         nickName: item['nick_name'],
//         phone: item['phone'],
//         description: item['description'],
//         isActive: item['isActive'] == 1,
//         address: Address.fromJson(addressMap),
//         amount: item['amount']?.toDouble(), // Retrieve amount
//       );
//       customers.add(customer);
//     }
//     return customers;
//   }
// }
// import 'dart:convert';
// import 'package:client_app/Core/Helper/constants.dart';
// import 'package:client_app/Core/Helper/snack_bar_helper.dart';
// import 'package:client_app/Feature/customer_list/customer_model/address.dart';
// import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
// import 'package:client_app/Core/Helper/DatabaseHelper.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:client_app/Feature/payment/cubit/payment_state.dart';

// class PaymentCubit extends Cubit<PaymentStates> {
//   final Dio _dio = Dio();
//   final DatabaseHelper databaseHelper = DatabaseHelper();
//   final List<Map<String, dynamic>> paymentQueue = [];
//   late final InternetConnectionChecker connectionChecker;
//   String? _token;

//   PaymentCubit() : super(PaymentInitial()) {
//     connectionChecker = InternetConnectionChecker();
//     _initializeToken();
//     monitorConnection();
//   }

//   static PaymentCubit get(context) => BlocProvider.of(context);

//   Future<void> _initializeToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     if (_token == null) {
//       print("Token not found in SharedPreferences.");
//     } else {
//       print("Token initialized: $_token");
//     }
//   }

//   Future<void> postPayment(id, bool? isRefund) async {
//     await fetchValueToSubtract(); // Fetch and store the value to be subtracted
//     final paymentData = {
//       'customer_id': id,
//       'isrefund': isRefund,
//     };

//     print("Attempting to post payment: $paymentData");

//     if (await isConnected()) {
//       print("Internet is connected, sending payment.");
//       await sendPayment(paymentData);
//     } else {
//       print("Internet is not connected, queuing payment.");
//       queuePayment(paymentData);
//     }
//   }

//   Future<void> sendPayment(Map<String, dynamic> paymentData) async {
//     emit(PaymentLoading());

//     try {
//       print("Sending payment: $paymentData");
//       await _dio.post(
//         "${Constants.baseUrl}${Constants.postPayment}",
//         data: paymentData,
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       // Subtract value from customer's amount in the local database
//       final prefs = await SharedPreferences.getInstance();
//       final subtractionValue = prefs.getDouble('subtractionValue') ?? 0.0;

//       print(
//           "Subtraction value retrieved from SharedPreferences: $subtractionValue");

//       // Fetch the current customer data
//       final customerId = paymentData['customer_id'];
//       final customerData = await databaseHelper.getCustomerById(customerId);

//       if (customerData != null) {
//         // Current amount for the customer
//         final currentAmount = customerData['amount'] ?? 0.0;
//         print("Current amount for customer ID $customerId: $currentAmount");

//         // Calculate the new amount
//         final newAmount = currentAmount - subtractionValue;
//         print("New calculated amount for customer ID $customerId: $newAmount");

//         // Update the customer's amount in the local database
//         await updateCustomerAmount(customerId, newAmount);
//         emit(UpdatedCustomerData());

//         // Fetch updated customer data
//         List<CustomerModel> updatedCustomerList = await fetchUpdatedCustomers();

//         // Emit updated state with the new customer data
//         emit(PaymentSuccess(updatedCustomerList));

//         print("Payment sent successfully and amount updated: $paymentData");
//         // showToast(text: "تم الدفع بنجاح وتم تحديث المبلغ", state: ToastStates.SUCCESS);
//       } else {
//         print("Customer with ID $customerId not found.");
//         emit(PaymentFailure());
//         // showToast(text: "العميل غير موجود", state: ToastStates.ERROR);
//       }
//     } catch (e) {
//       print("Failed to send payment: $e");
//       queuePayment(paymentData);
//       emit(PaymentFailure());
//     }
//   }

//   Future<void> fetchValueToSubtract() async {
//     try {
//       final response = await _dio.get(
//         "https://momen-three.vercel.app/customers/get_main_value/",
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       final valueToSubtract = response.data['value']?.toDouble() ?? 0.0;
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('subtractionValue', valueToSubtract);

//       print("Fetched and stored subtraction value: $valueToSubtract");
//     } catch (e) {
//       print("Failed to fetch value: $e");
//     }
//   }

//   void queuePayment(Map<String, dynamic> paymentData) {
//     paymentQueue.add(paymentData);
//     print("Payment added to queue: $paymentData");
//     showToast(
//         text: "تمت إضافة الدفع إلى قائمة الانتظار", // Arabic message
//         state: ToastStates.WARNING);
//   }

//   Future<bool> isConnected() async {
//     bool connectionStatus = await connectionChecker.hasConnection;
//     print("Connection status: $connectionStatus");
//     showToast(
//         text: "حالة الاتصال: $connectionStatus", state: ToastStates.WARNING);
//     return connectionStatus;
//   }

//   void monitorConnection() {
//     connectionChecker.onStatusChange.listen((status) {
//       print("Internet connection status changed: $status");
//       if (status == InternetConnectionStatus.connected) {
//         print("Processing queued payments.");
//         processQueue();
//       }
//     });
//   }

//   void processQueue() {
//     if (paymentQueue.isNotEmpty) {
//       print("Processing payment queue: $paymentQueue");
//       List<Map<String, dynamic>> queueToProcess = List.from(paymentQueue);
//       paymentQueue
//           .clear(); // Clear the queue before processing to avoid duplication

//       for (var payment in queueToProcess) {
//         sendPayment(payment);
//       }
//     } else {
//       print("Queue is empty.");
//     }
//   }

//   Future<void> updateCustomerAmount(int customerId, double newAmount) async {
//     await databaseHelper.updateCustomerAmount(customerId, newAmount);
//   }

//   Future<List<CustomerModel>> fetchUpdatedCustomers() async {
//     final data = await databaseHelper.getCustomers();
//     List<CustomerModel> customers = [];
//     for (var item in data) {
//       var addressMap = jsonDecode(item['address']) as Map<String, dynamic>;
//       var customer = CustomerModel(
//         id: item['id'],
//         name: item['name'],
//         collectDay: item['collect_day'],
//         nickName: item['nick_name'],
//         phone: item['phone'],
//         description: item['description'],
//         isActive: item['isActive'] == 1,
//         address: Address.fromJson(addressMap),
//         amount: item['amount']?.toDouble(), // Retrieve amount
//       );
//       customers.add(customer);
//     }
//     return customers;
//   }
// }
// import 'dart:convert';
// import 'package:client_app/Core/Helper/constants.dart';
// import 'package:client_app/Core/Helper/snack_bar_helper.dart';
// import 'package:client_app/Feature/customer_list/customer_model/address.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:client_app/Feature/payment/cubit/payment_state.dart';
// import 'package:client_app/Core/Helper/DatabaseHelper.dart';
// import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';

// class PaymentCubit extends Cubit<PaymentStates> {
//   final Dio _dio = Dio();
//   final DatabaseHelper databaseHelper =
//       DatabaseHelper(); // Instantiate DatabaseHelper
//   List<Map<String, dynamic>> paymentQueue = [];
//   late InternetConnectionChecker connectionChecker;
//   String? _token; // Store token as a member variable

//   PaymentCubit() : super(PaymentInitial()) {
//     _initializeToken(); // Initialize token

//     connectionChecker = InternetConnectionChecker();
//     monitorConnection();
//   }

//   static PaymentCubit get(context) => BlocProvider.of(context);
//   Future<void> _initializeToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     if (_token == null) {
//       print("Token not found in SharedPreferences.");
//     } else {
//       print("Token initialized: $_token");
//     }
//   }

//   Future<void> postPayment(id, bool? isRefund) async {
//     await fetchValueToSubtract(); // Fetch and store the value to be subtracted
//     final paymentData = {
//       'customer_id': id,
//       'isrefund': isRefund,
//     };

//     print("Attempting to post payment: $paymentData");

//     if (await isConnected()) {
//       print("Internet is connected, sending payment.");

//       await sendPayment(paymentData);
//     } else {
//       print("Internet is not connected, queuing payment.");
//       queuePayment(paymentData);
//     }
//   }

//   Future<void> sendPayment(Map<String, dynamic> paymentData) async {
//     emit(PaymentLoading());

//     try {
//       print("Sending payment: $paymentData");
//       await _dio.post(
//         "${Constants.baseUrl}${Constants.postPayment}",
//         data: paymentData,
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       // Subtract value from customer's amount in the local database
//       final prefs = await SharedPreferences.getInstance();
//       final subtractionValue = prefs.getDouble('subtractionValue') ?? 0.0;

//       print(
//           "Subtraction value retrieved from SharedPreferences: $subtractionValue");

//       // Fetch the current customer data
//       final customerId = paymentData['customer_id'];
//       final customerData = await databaseHelper.getCustomerById(customerId);

//       if (customerData != null) {
//         // Current amount for the customer
//         final currentAmount = customerData['amount'] ?? 0.0;
//         print("Current amount for customer ID $customerId: $currentAmount");

//         // Calculate the new amount
//         final newAmount = currentAmount - subtractionValue;
//         print("New calculated amount for customer ID $customerId: $newAmount");

//         // Update the customer's amount in the local database
//         await updateCustomerAmount(customerId, newAmount);

//         // Fetch updated customer data
//         List<CustomerModel> updatedCustomerList = await fetchUpdatedCustomers();

//         // Emit updated state with the new customer data
//         emit(PaymentSuccess(updatedCustomerList));

//         debugPrint(
//             "Payment sent successfully and amount updated: $paymentData");
//         // showToast(
//         //     text: "تم الدفع بنجاح وتم تحديث المبلغ",
//         //     state: ToastStates.SUCCESS);
//       } else {
//         print("Customer with ID $customerId not found.");
//         emit(PaymentFailure());
//         // showToast(text: "العميل غير موجود", state: ToastStates.ERROR);
//       }
//     } catch (e) {
//       print("Failed to send payment: $e");
//       queuePayment(paymentData);

//       // Emit failure state
//       emit(PaymentFailure());
//     }
//   }

//   Future<void> fetchValueToSubtract() async {
//     try {
//       final response = await _dio.get(
//         "https://momen-three.vercel.app/customers/get_main_value/",
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       // Assuming the response contains the value to subtract
//       final valueToSubtract = response.data['value']?.toDouble() ?? 0.0;

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('subtractionValue', valueToSubtract);

//       print("Fetched and stored subtraction value: $valueToSubtract");
//     } catch (e) {
//       print("Failed to fetch value: $e");
//     }
//   }

//   void queuePayment(Map<String, dynamic> paymentData) {
//     paymentQueue.add(paymentData);
//     // emit(Paymentaddeddtoqueuee());
//     print("Payment added to queue: $paymentData");
//     showToast(
//         text: "تمت إضافة الدفع إلى قائمة الانتظار", // Arabic message
//         state: ToastStates.SUCCESS);
//   }

//   Future<bool> isConnected() async {
//     bool connectionStatus = await connectionChecker.hasConnection;
//     print("Connection status: $connectionStatus");
//     // showToast(
//     //     text: "حالة الاتصال: $connectionStatus", state: ToastStates.WARNING);

//     return connectionStatus;
//   }

//   void monitorConnection() {
//     connectionChecker.onStatusChange.listen((status) {
//       print("Internet connection status changed: $status");
//       if (status == InternetConnectionStatus.connected) {
//         print("Processing queued payments.");
//         processQueue();
//       }
//     });
//   }

//   void processQueue() {
//     if (paymentQueue.isNotEmpty) {
//       print("Processing payment queue: $paymentQueue");
//       for (var payment in paymentQueue) {
//         sendPayment(payment);
//       }
//       paymentQueue.clear();
//       print("Payment queue cleared.");
//     } else {
//       print("قائمة الانتظار فارغة.");
//     }
//   }

//   Future<void> updateCustomerAmount(int customerId, double newAmount) async {
//     // Update the customer's amount in the local database
//     await databaseHelper.updateCustomerAmount(customerId, newAmount);
//   }

//   Future<List<CustomerModel>> fetchUpdatedCustomers() async {
//     final data = await databaseHelper.getCustomers();
//     List<CustomerModel> customers = [];
//     for (var item in data) {
//       var addressMap = jsonDecode(item['address']) as Map<String, dynamic>;
//       var customer = CustomerModel(
//         id: item['id'],
//         name: item['name'],
//         collectDay: item['collect_day'],
//         nickName: item['nick_name'],
//         phone: item['phone'],
//         description: item['description'],
//         isActive: item['isActive'] == 1,
//         address: Address.fromJson(addressMap),
//         amount: item['amount']?.toDouble(), // Retrieve amount
//       );
//       customers.add(customer);
//     }
//     return customers;
//   }
// }

// import 'dart:convert';
// import 'package:client_app/Core/Helper/constants.dart';
// import 'package:client_app/Core/Helper/snack_bar_helper.dart';
// import 'package:client_app/Feature/customer_list/customer_model/address.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:client_app/Feature/payment/cubit/payment_state.dart';
// import 'package:client_app/Core/Helper/DatabaseHelper.dart';
// import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';

// class PaymentCubit extends Cubit<PaymentStates> {
//   final Dio _dio = Dio();
//   final DatabaseHelper databaseHelper =
//       DatabaseHelper(); // Instantiate DatabaseHelper
//   List<Map<String, dynamic>> paymentQueue = [];
//   late InternetConnectionChecker connectionChecker;
//   String? _token; // Store token as a member variable

//   PaymentCubit() : super(PaymentInitial()) {
//     _initializeToken(); // Initialize token
//     connectionChecker = InternetConnectionChecker();
//     monitorConnection();
//   }

//   static PaymentCubit get(context) => BlocProvider.of(context);

//   Future<void> _initializeToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//     if (_token == null) {
//       print("Token not found in SharedPreferences.");
//     } else {
//       print("Token initialized: $_token");
//     }
//   }

//   /// Function to send a standard payment with refund set to false
//   Future<void> sendPayment(int id) async {
//     await fetchValueToSubtract(); // Fetch and store the value to be subtracted
//     final paymentData = {
//       'customer_id': id,
//       'isrefund': false, // Set refund to false
//     };

//     print("Attempting to send payment: $paymentData");

//     if (await isConnected()) {
//       print("Internet is connected, processing payment.");
//       await processPaymentRequest(paymentData, subtract: true);
//     } else {
//       queuePayment(paymentData);

//       print("Internet is not connected, queuing payment.");
//     }
//   }

//   Future<void> refundPayment(customerId) async {
//     // Define refund request data
//     final refundData = {
//       'customer_id': customerId,
//       'isrefund': true,
//     };

//     print("Attempting to refund payment: $refundData");

//     if (await isConnected()) {
//       print("Internet is connected, sending refund.");

//       try {
//         emit(PaymentLoading());

//         // Send refund request
//         final response = await _dio.post(
//           "${Constants.baseUrl}${Constants.postPayment}", // Ensure this endpoint supports refund
//           data: refundData,
//           options: Options(
//             headers: {
//               'Accept': 'application/json',
//               'Accept-Language': 'ar',
//               "Authorization": "Token $_token",
//             },
//           ),
//         );

//         // Check if the response indicates success
//         if (response.statusCode == 200) {
//           // Fetch the current customer data
//           final customerData = await databaseHelper.getCustomerById(customerId);

//           if (customerData != null) {
//             // Current amount for the customer
//             final currentAmount = customerData['amount'] ?? 0.0;
//             print("Current amount for customer ID $customerId: $currentAmount");

//             // Add the subtraction value to the amount
//             final prefs = await SharedPreferences.getInstance();
//             final subtractionValue = prefs.getDouble('subtractionValue') ?? 0.0;
//             final newAmount = currentAmount + subtractionValue;
//             print(
//                 "New calculated amount for customer ID $customerId: $newAmount");

//             // Update the customer's amount in the local database
//             await updateCustomerAmount(customerId, newAmount);

//             // Fetch updated customer data
//             List<CustomerModel> updatedCustomerList =
//                 await fetchUpdatedCustomers();

//             // Emit updated state with the new customer data
//             emit(PaymentSuccess(updatedCustomerList));

//             debugPrint(
//                 "Refund processed successfully and amount updated: $refundData");

//             // Show a success toast
//             showToast(
//               text: "تمت معالجة الاسترداد بنجاح وتم تحديث المبلغ",
//               state: ToastStates.SUCCESS,
//             );
//           } else {
//             print("Customer with ID $customerId not found.");
//             emit(PaymentFailure());
//             // Show an error toast
//             showToast(
//               text: "العميل غير موجود",
//               state: ToastStates.ERROR,
//             );
//           }
//         } else {
//           // Handle server response error
//           print("Server responded with status code: ${response.statusCode}");
//           queuePayment(refundData);
//           emit(PaymentFailure());
//           showToast(
//             text: "فشل في معالجة الاسترداد",
//             state: ToastStates.ERROR,
//           );
//         }
//       } catch (e) {
//         // Handle request error
//         print("Failed to process refund: $e");
//         // queuePayment(refundData);

//         // Emit failure state
//         emit(PaymentFailure());

//         // Show an error toast
//         showToast(
//           text: "فشل في معالجة الاسترداد",
//           state: ToastStates.ERROR,
//         );
//       }
//     } else {
//       print("Internet is not connected, queuing refund.");
//       queuePayment(refundData);
//     }
//   }

//   /// Helper function to process payment requests
//   Future<void> processPaymentRequest(
//     Map<String, dynamic> paymentData, {
//     required bool subtract,
//   }) async {
//     emit(PaymentLoading());

//     try {
//       print("Sending request: $paymentData");
//       await _dio.post(
//         "${Constants.baseUrl}${Constants.postPayment}",
//         data: paymentData,
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       // Adjust value in the local database based on the operation
//       final prefs = await SharedPreferences.getInstance();
//       final valueToAdjust = prefs.getDouble('subtractionValue') ?? 0.0;

//       print("Value to adjust: $valueToAdjust");

//       // Fetch the current customer data
//       final customerId = paymentData['customer_id'];
//       final customerData = await databaseHelper.getCustomerById(customerId);

//       if (customerData != null) {
//         // Current amount for the customer
//         final currentAmount = customerData['amount'] ?? 0.0;
//         print("Current amount for customer ID $customerId: $currentAmount");

//         // Calculate the new amount based on the operation
//         final newAmount = subtract
//             ? currentAmount - valueToAdjust
//             : currentAmount + valueToAdjust;
//         print("New amount for customer ID $customerId: $newAmount");

//         // Update the customer's amount in the local database
//         await updateCustomerAmount(customerId, newAmount);

//         // Fetch updated customer data
//         List<CustomerModel> updatedCustomerList = await fetchUpdatedCustomers();

//         // Emit updated state with the new customer data
//         emit(PaymentSuccess(updatedCustomerList));

//         final action = subtract ? "الدفع" : "رد المبلغ";
//         debugPrint("$action تم بنجاح وتم تحديث المبلغ: $paymentData");

//         // Show a success toast
//         showToast(
//           text: "$action تم بنجاح وتم تحديث المبلغ",
//           state: ToastStates.SUCCESS,
//         );
//       } else {
//         print("Customer with ID $customerId not found.");
//         emit(PaymentFailure());
//         // Show an error toast
//         showToast(
//           text: "العميل غير موجود",
//           state: ToastStates.ERROR,
//         );
//       }
//     } catch (e) {
//       print("Failed to process request: $e");
//       queuePayment(paymentData);

//       // Emit failure state
//       emit(PaymentFailure());

//       // Show an error toast
//       showToast(
//         text: "فشل في معالجة الطلب",
//         state: ToastStates.ERROR,
//       );
//     }
//   }

//   Future<void> fetchValueToSubtract() async {
//     try {
//       final response = await _dio.get(
//         "https://momen-three.vercel.app/customers/get_main_value/",
//         options: Options(
//           headers: {
//             'Accept': 'application/json',
//             'Accept-Language': 'ar',
//             "Authorization": "Token $_token",
//           },
//         ),
//       );

//       // Assuming the response contains the value to subtract
//       final valueToSubtract = response.data['value']?.toDouble() ?? 0.0;

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('subtractionValue', valueToSubtract);

//       print("Fetched and stored subtraction value: $valueToSubtract");
//     } catch (e) {
//       print("Failed to fetch value: $e");
//     }
//   }

//   void queuePayment(Map<String, dynamic> paymentData) {
//     paymentQueue.add(paymentData);
//     // emit(PaymentAddedToQueue(
//     //     paymentData)); // Emit a specific state for queued payment
//     print("Payment added to queue: $paymentData");
//     showToast(
//         text: "تم الاضافه الى قائمه الانتظار", state: ToastStates.SUCCESS);
//   }

//   Future<bool> isConnected() async {
//     bool connectionStatus = await connectionChecker.hasConnection;
//     print("Connection status: $connectionStatus");
//     return connectionStatus;
//   }

//   void monitorConnection() {
//     connectionChecker.onStatusChange.listen((status) {
//       print("Internet connection status changed: $status");
//       if (status == InternetConnectionStatus.connected) {
//         print("Processing queued payments.");
//         processQueue();
//       }
//     });
//   }

//   void processQueue() {
//     if (paymentQueue.isNotEmpty) {
//       print("Processing payment queue: $paymentQueue");
//       for (var payment in paymentQueue) {
//         // Check refund status for each payment in the queue
//         final isRefund = payment['isrefund'] ?? false;
//         if (isRefund) {
//           refundPayment(payment['customer_id']); // Process refund
//         } else {
//           sendPayment(payment['customer_id']); // Process payment
//         }
//       }
//       paymentQueue.clear(); // Clear the queue after processing
//     }
//   }

//   Future<List<CustomerModel>> fetchUpdatedCustomers() async {
//     final data = await databaseHelper.getCustomers();
//     List<CustomerModel> customers = [];
//     for (var item in data) {
//       var addressMap = jsonDecode(item['address']) as Map<String, dynamic>;
//       var customer = CustomerModel(
//         id: item['id'],
//         name: item['name'],
//         collectDay: item['collect_day'],
//         nickName: item['nick_name'],
//         phone: item['phone'],
//         description: item['description'],
//         isActive: item['isActive'] == 1,
//         address: Address.fromJson(addressMap),
//         amount: item['amount']?.toDouble(), // Retrieve amount
//       );
//       customers.add(customer);
//     }
//     return customers;
//   }

//   Future<void> updateCustomerAmount(int customerId, double newAmount) async {
//     await databaseHelper.updateCustomerAmount(customerId, newAmount);
//     print("Customer amount updated for ID $customerId: $newAmount");
//   }
// }
import 'dart:convert';
import 'package:client_app/Core/Helper/constants.dart';
import 'package:client_app/Feature/customer_list/customer_model/address.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_app/Feature/payment/cubit/payment_state.dart';
import 'package:client_app/Core/Helper/DatabaseHelper.dart';
import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';

class PaymentCubit extends Cubit<PaymentStates> {
  final Dio _dio = Dio();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> paymentQueue = [];
  late InternetConnectionChecker connectionChecker;
  String? _token;

  PaymentCubit() : super(PaymentInitial()) {
    _initializeToken();
    connectionChecker = InternetConnectionChecker();
    _monitorConnection();
  }

  static PaymentCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> _initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token == null) {
      print("Token not found in SharedPreferences.");
    } else {
      print("Token initialized: $_token");
    }
  }

  Future<void> postPayment(id, bool? isRefund) async {
    final paymentData = {
      'customer_id': id,
      'isrefund': isRefund,
    };

    print("Attempting to post payment: $paymentData");

    if (await _isConnected()) {
      await _sendPayment(paymentData);
    } else {
      _queuePayment(paymentData);
      emit(PaymentAddedToQueue(paymentData));
    }
  }

  Future<void> _sendPayment(Map<String, dynamic> paymentData) async {
    emit(PaymentLoading());

    try {
      print("Sending payment: $paymentData");
      await _dio.post(
        "${Constants.baseUrl}${Constants.postPayment}",
        data: paymentData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Accept-Language': 'ar',
            "Authorization": "Token $_token",
          },
        ),
      );

      final subtractionValue = await _fetchValueToSubtract();
      final customerId = paymentData['customer_id'];
      final customerData = await databaseHelper.getCustomerById(customerId);

      if (customerData != null) {
        final currentAmount = customerData['amount'] ?? 0.0;
        final newAmount = currentAmount - subtractionValue;
        await _updateCustomerAmount(customerId, newAmount);
        final updatedCustomerList = await _fetchUpdatedCustomers();
        emit(PaymentSuccess(updatedCustomerList));
      } else {
        emit(PaymentFailure());
      }
    } catch (e) {
      print("Failed to send payment: $e");
      _queuePayment(paymentData);
      emit(PaymentFailure());
    }
  }

  Future<double> _fetchValueToSubtract() async {
    try {
      final response = await _dio.get(
        "https://momen-three.vercel.app/customers/get_main_value/",
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Accept-Language': 'ar',
            "Authorization": "Token $_token",
          },
        ),
      );

      final valueToSubtract = response.data['value']?.toDouble() ?? 0.0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('subtractionValue', valueToSubtract);

      print("Fetched and stored subtraction value: $valueToSubtract");
      return valueToSubtract;
    } catch (e) {
      print("Failed to fetch value: $e");
      return 0.0;
    }
  }

  void _queuePayment(Map<String, dynamic> paymentData) {
    paymentQueue.add(paymentData);
    print("Payment added to queue: $paymentData");
    emit(PaymentAddedToQueue(paymentData));
  }

  Future<bool> _isConnected() async {
    bool connectionStatus = await connectionChecker.hasConnection;
    print("Connection status: $connectionStatus");
    return connectionStatus;
  }

  void _monitorConnection() {
    connectionChecker.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        _processQueue();
      }
    });
  }

  void _processQueue() {
    if (paymentQueue.isNotEmpty) {
      print("Processing payment queue: $paymentQueue");
      for (var payment in List.from(paymentQueue)) {
        _sendPayment(payment);
      }
      paymentQueue.clear();
      print("Payment queue cleared.");
    } else {
      print("قائمة الانتظار فارغة.");
    }
  }

  Future<void> _updateCustomerAmount(int customerId, double newAmount) async {
    await databaseHelper.updateCustomerAmount(customerId, newAmount);
  }

  Future<List<CustomerModel>> _fetchUpdatedCustomers() async {
    final data = await databaseHelper.getCustomers();
    return data.map((item) {
      var addressMap = jsonDecode(item['address']) as Map<String, dynamic>;
      return CustomerModel(
        id: item['id'],
        name: item['name'],
        collectDay: item['collect_day'],
        nickName: item['nick_name'],
        phone: item['phone'],
        description: item['description'],
        isActive: item['isActive'] == 1,
        address: Address.fromJson(addressMap),
        amount: item['amount']?.toDouble(),
      );
    }).toList();
  }

  Future<void> refundPayment(int customerId) async {
    final refundData = {
      'customer_id': customerId,
      'is_refund': true,
    };

    print("Attempting to refund payment: $refundData");

    if (await _isConnected()) {
      print("Internet is connected, sending refund.");

      try {
        emit(RefundLoading());

        final response = await _dio.post(
          "${Constants.baseUrl}${Constants.postPayment}",
          data: refundData,
          options: Options(
            headers: {
              "Authorization": "Token $_token",
            },
          ),
        );

        if (response.statusCode == 201) {
          final customerData = await databaseHelper.getCustomerById(customerId);

          if (customerData != null) {
            final currentAmount = customerData['amount'] ?? 0.0;
            final prefs = await SharedPreferences.getInstance();
            final subtractionValue = prefs.getDouble('subtractionValue') ?? 0.0;
            final newAmount = currentAmount + subtractionValue;

            await _updateCustomerAmount(customerId, newAmount);

            List<CustomerModel> updatedCustomerList =
                await _fetchUpdatedCustomers();

            emit(RefundSuccess());

            debugPrint(
                "Refund processed successfully and amount updated: $refundData");
          } else {
            print("Customer with ID $customerId not found.");
            emit(RefundFailure());
          }
        } else {
          print("Server responded with status code: ${response.statusCode}");
          _queuePayment(refundData);
          emit(RefundFailure());
        }
      } catch (e) {
        print("Failed to process refund: $e");
        emit(RefundFailure());
      }
    } else {
      print("Internet is not connected, queuing refund.");
      _queuePayment(refundData);
      emit(RefundFailure());
    }
  }
  // Future<void> refundPayment(int customerId) async {
  //   // Define refund request data
  //   final refundData = {
  //     'customer_id': customerId,
  //     'is_refund': true,
  //   };

  //   print("Attempting to refund payment: $refundData");

  //   if (await _isConnected()) {
  //     print("Internet is connected, sending refund.");

  //     try {
  //       emit(PaymentLoading());

  //       // Send refund request
  //       final response = await _dio.post(
  //         "${Constants.baseUrl}${Constants.postPayment}", // Ensure this endpoint supports refund
  //         data: refundData,
  //         options: Options(
  //           headers: {
  //             "Authorization": "Token $_token",
  //           },
  //         ),
  //       );

  //       // Check if the response indicates success
  //       if (response.statusCode == 200) {
  //         // Fetch the current customer data
  //         final customerData = await databaseHelper.getCustomerById(customerId);

  //         if (customerData != null) {
  //           // Current amount for the customer
  //           final currentAmount = customerData['amount'] ?? 0.0;
  //           print("Current amount for customer ID $customerId: $currentAmount");

  //           // Add the subtraction value to the amount
  //           final prefs = await SharedPreferences.getInstance();
  //           final subtractionValue = prefs.getDouble('subtractionValue') ?? 0.0;
  //           final newAmount = currentAmount + subtractionValue;
  //           print(
  //               "New calculated amount for customer ID $customerId: $newAmount");

  //           // Update the customer's amount in the local database
  //           await _updateCustomerAmount(customerId, newAmount);

  //           // Fetch updated customer data
  //           List<CustomerModel> updatedCustomerList =
  //               await _fetchUpdatedCustomers();

  //           // Emit updated state with the new customer data
  //           emit(PaymentSuccess(updatedCustomerList));

  //           debugPrint(
  //               "Refund processed successfully and amount updated: $refundData");

  //           // Show a success toast
  //         } else {
  //           print("Customer with ID $customerId not found.");
  //           emit(PaymentFailure());
  //           // Show an error toast
  //         }
  //       } else {
  //         // Handle server response error
  //         print("Server responded with status code: ${response.statusCode}");
  //         _queuePayment(refundData);
  //         emit(PaymentFailure());
  //       }
  //     } catch (e) {
  //       // Handle request error
  //       print("Failed to process refund: $e");

  //       // Emit failure state
  //       emit(PaymentFailure());

  //       // Show an error toast
  //     }
  //   } else {
  //     print("Internet is not connected, queuing refund.");
  //     _queuePayment(refundData);
  //   }
  // }
}
