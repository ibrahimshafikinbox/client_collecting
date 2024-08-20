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
}
