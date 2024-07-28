import 'package:client_app/Feature/customer_list/customer_model/address.dart';

class CustomerModel {
  int id;
  String name;
  int collectDay;
  String nickName;
  String phone;
  String description;
  bool isActive;
  Address? address;
  double? amount; // Add amount field

  CustomerModel({
    required this.id,
    required this.name,
    required this.collectDay,
    required this.nickName,
    required this.phone,
    required this.description,
    required this.isActive,
    this.address,
    this.amount,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      collectDay: json['collect_day'] ?? 0,
      nickName: json['nick_name'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] == 1,
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      amount: json['amount'] != null
          ? json['amount'].toDouble()
          : null, // Deserialize amount
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['collect_day'] = this.collectDay;
    data['nick_name'] = this.nickName;
    data['phone'] = this.phone;
    data['description'] = this.description;
    data['isActive'] = this.isActive ? 1 : 0;
    if (this.address != null) {
      data['address'] = this.address?.toJson();
    }
    data['amount'] = this.amount; // Serialize amount
    return data;
  }
}
