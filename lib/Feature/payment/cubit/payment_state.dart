// payment_state.dart
import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';

abstract class PaymentStates {}

class PaymentInitial extends PaymentStates {}

class PaymentLoading extends PaymentStates {}

class PaymentSuccess extends PaymentStates {
  final List<CustomerModel> updatedCustomerList;

  PaymentSuccess(this.updatedCustomerList);
}

class PaymentFailure extends PaymentStates {}

class Paymentaddeddtoqueuee extends PaymentStates {}
