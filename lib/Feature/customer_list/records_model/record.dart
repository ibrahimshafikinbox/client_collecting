import 'customer.dart';

class Record {
  int? id;
  Customer? customer;
  String? collector;
  int? amount;
  bool? isRefund;
  DateTime? createdAt;

  Record({
    this.id,
    this.customer,
    this.collector,
    this.amount,
    this.isRefund,
    this.createdAt,
  });

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        id: json['id'] as int?,
        customer: json['customer'] == null
            ? null
            : Customer.fromJson(json['customer'] as Map<String, dynamic>),
        collector: json['collector'] as String?,
        amount: json['amount'] as int?,
        isRefund: json['is_refund'] as bool?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer?.toJson(),
        'collector': collector,
        'amount': amount,
        'is_refund': isRefund,
        'created_at': createdAt?.toIso8601String(),
      };
}
