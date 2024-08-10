import 'package:client_app/Feature/customer_list/customer_model/customer_model.dart';
import 'package:client_app/Feature/customer_list/records_model/records_model.dart';

abstract class GetCustomerState {
  const GetCustomerState();
}

class GetCustomerInitial extends GetCustomerState {
  const GetCustomerInitial();
}

class GetCustomerLoading extends GetCustomerState {}

class UNAouthorization extends GetCustomerState {}

class GetCustomerSuccess extends GetCustomerState {
  final List<CustomerModel> customers;

  GetCustomerSuccess(this.customers);
}

class GetCustomerError extends GetCustomerState {
  final String message;

  GetCustomerError(this.message);
}

class GetRecordsLoading extends GetCustomerState {}

class GetRecordsSuccess extends GetCustomerState {
  final RecordsModel recordsModel;
  GetRecordsSuccess(this.recordsModel);
}

class GetRecordsError extends GetCustomerState {
  final String error;
  GetRecordsError(this.error);
}
