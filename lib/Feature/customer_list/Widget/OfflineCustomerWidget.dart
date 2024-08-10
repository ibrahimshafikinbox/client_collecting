import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
// Define states for PaymentCubit
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:convert';
import 'package:client_app/Core/Helper/constants.dart';
import 'package:client_app/Core/Helper/snack_bar_helper.dart';
import 'package:client_app/Feature/customer_list/customer_model/address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_app/Core/Helper/DatabaseHelper.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => paymentCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Queue Test'),
        ),
        body: BlocConsumer<paymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment sent successfully!')),
              );
            } else if (state is PaymentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Payment queued due to no connection.')),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  // Example payment data
                  final paymentData = {
                    'customer_id': 1993,
                    'amount': 100.0,
                    'is_refund': false,
                  };

                  // Trigger the payment process
                  BlocProvider.of<paymentCubit>(context)
                      .postPayment(4444, false);
                },
                child: state is PaymentLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Post Payment'),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Define the states for PaymentCubit
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {}

class PaymentFailure extends PaymentState {}

// Payment Cubit class

class paymentCubit extends Cubit<PaymentState> {
  final Dio _dio = Dio();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> paymentQueue = [];
  late InternetConnectionChecker connectionChecker;
  String? _token;

  paymentCubit() : super(PaymentInitial()) {
    _initializeToken();
    connectionChecker = InternetConnectionChecker();
    _monitorConnection();
  }

  static paymentCubit get(context) => BlocProvider.of(context);

  Future<void> _initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token == null) {
      print("Token not found in SharedPreferences.");
    } else {
      print("Token initialized: $_token");
    }
  }

  Future<void> postPayment(int id, bool? isRefund) async {
    final paymentData = {
      'customer_id': id,
      'isrefund': isRefund,
    };

    print("Attempting to post payment: $paymentData");

    if (await _isConnected()) {
      await _sendPayment(paymentData);
    } else {
      print((">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>..."));
      _queuePayment(paymentData);
      emit(PaymentFailure());
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
        showToast(
          text: "تم الدفع بنجاح وتم تحديث المبلغ",
          state: ToastStates.SUCCESS,
        );
      } else {
        emit(PaymentFailure());
        showToast(
          text: "العميل غير موجود",
          state: ToastStates.ERROR,
        );
      }
    } catch (e) {
      print("Failed to send payment: $e");
      _queuePayment(paymentData);
      emit(PaymentFailure());
      showToast(
        text: "فشل في إرسال الدفع",
        state: ToastStates.ERROR,
      );
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
    showToast(
      text: "تم الاضافه الى قائمه الانتظار",
      state: ToastStates.SUCCESS,
    );
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
}
