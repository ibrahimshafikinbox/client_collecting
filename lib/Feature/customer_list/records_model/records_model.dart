import 'record.dart';

class RecordsModel {
  int? count;
  int? totalAmount;
  List<Record>? records;

  RecordsModel({this.count, this.totalAmount, this.records});

  factory RecordsModel.fromJson(Map<String, dynamic> json) => RecordsModel(
        count: json['count'] as int?,
        totalAmount: json['total_amount'] as int?,
        records: (json['records'] as List<dynamic>?)
            ?.map((e) => Record.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'total_amount': totalAmount,
        'records': records?.map((e) => e.toJson()).toList(),
      };
}
