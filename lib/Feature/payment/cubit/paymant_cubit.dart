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
  final DatabaseHelper databaseHelper =
      DatabaseHelper(); // Instantiate DatabaseHelper
  List<Map<String, dynamic>> paymentQueue = [];
  late InternetConnectionChecker connectionChecker;
  String? _token; // Store token as a member variable

  PaymentCubit() : super(PaymentInitial()) {
    _initializeToken(); // Initialize token

    connectionChecker = InternetConnectionChecker();
    monitorConnection();
  }

  static PaymentCubit get(context) => BlocProvider.of(context);
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
    await fetchValueToSubtract(); // Fetch and store the value to be subtracted
    final paymentData = {
      'customer_id': id,
      'isrefund': isRefund,
    };

    print("Attempting to post payment: $paymentData");

    if (await isConnected()) {
      print("Internet is connected, sending payment.");

      await sendPayment(paymentData);
    } else {
      print("Internet is not connected, queuing payment.");
      queuePayment(paymentData);
    }
  }

  Future<void> sendPayment(Map<String, dynamic> paymentData) async {
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

      // Subtract value from customer's amount in the local database
      final prefs = await SharedPreferences.getInstance();
      final subtractionValue = prefs.getDouble('subtractionValue') ?? 0.0;

      print(
          "Subtraction value retrieved from SharedPreferences: $subtractionValue");

      // Fetch the current customer data
      final customerId = paymentData['customer_id'];
      final customerData = await databaseHelper.getCustomerById(customerId);

      if (customerData != null) {
        // Current amount for the customer
        final currentAmount = customerData['amount'] ?? 0.0;
        print("Current amount for customer ID $customerId: $currentAmount");

        // Calculate the new amount
        final newAmount = currentAmount - subtractionValue;
        print("New calculated amount for customer ID $customerId: $newAmount");

        // Update the customer's amount in the local database
        await updateCustomerAmount(customerId, newAmount);

        // Fetch updated customer data
        List<CustomerModel> updatedCustomerList = await fetchUpdatedCustomers();

        // Emit updated state with the new customer data
        emit(PaymentSuccess(updatedCustomerList));

        debugPrint(
            "Payment sent successfully and amount updated: $paymentData");
        // showToast(
        //     text: "تم الدفع بنجاح وتم تحديث المبلغ",
        //     state: ToastStates.SUCCESS);
      } else {
        print("Customer with ID $customerId not found.");
        emit(PaymentFailure());
        // showToast(text: "العميل غير موجود", state: ToastStates.ERROR);
      }
    } catch (e) {
      print("Failed to send payment: $e");
      queuePayment(paymentData);

      // Emit failure state
      emit(PaymentFailure());
    }
  }

  Future<void> fetchValueToSubtract() async {
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

      // Assuming the response contains the value to subtract
      final valueToSubtract = response.data['value']?.toDouble() ?? 0.0;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('subtractionValue', valueToSubtract);

      print("Fetched and stored subtraction value: $valueToSubtract");
    } catch (e) {
      print("Failed to fetch value: $e");
    }
  }

  void queuePayment(Map<String, dynamic> paymentData) {
    paymentQueue.add(paymentData);
    emit(Paymentaddeddtoqueuee());
    print("Payment added to queue: $paymentData");
    // showToast(
    //     text: "تمت إضافة الدفع إلى قائمة الانتظار", // Arabic message
    //     state: ToastStates.WARNING);
  }

  Future<bool> isConnected() async {
    bool connectionStatus = await connectionChecker.hasConnection;
    print("Connection status: $connectionStatus");
    // showToast(
    //     text: "حالة الاتصال: $connectionStatus", state: ToastStates.WARNING);

    return connectionStatus;
  }

  void monitorConnection() {
    connectionChecker.onStatusChange.listen((status) {
      print("Internet connection status changed: $status");
      if (status == InternetConnectionStatus.connected) {
        print("Processing queued payments.");
        processQueue();
      }
    });
  }

  void processQueue() {
    if (paymentQueue.isNotEmpty) {
      print("Processing payment queue: $paymentQueue");
      for (var payment in paymentQueue) {
        sendPayment(payment);
      }
      paymentQueue.clear();
      print("Payment queue cleared.");
    } else {
      print("قائمة الانتظار فارغة.");
    }
  }

  Future<void> updateCustomerAmount(int customerId, double newAmount) async {
    // Update the customer's amount in the local database
    await databaseHelper.updateCustomerAmount(customerId, newAmount);
  }

  Future<List<CustomerModel>> fetchUpdatedCustomers() async {
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
}
