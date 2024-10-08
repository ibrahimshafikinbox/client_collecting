import 'customer.dart';

class NotesModel {
  int? id;
  Customer? customer;
  int? noteType;
  bool? isSolved;
  DateTime? createdAt;

  NotesModel({
    this.id,
    this.customer,
    this.noteType,
    this.isSolved,
    this.createdAt,
  });

  factory NotesModel.fromJson(Map<String, dynamic> json) => NotesModel(
        id: json['id'] as int?,
        customer: json['customer'] == null
            ? null
            : Customer.fromJson(json['customer'] as Map<String, dynamic>),
        noteType: json['note_type'] as int?,
        isSolved: json['is_solved'] as bool?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer?.toJson(),
        'note_type': noteType,
        'is_solved': isSolved,
        'created_at': createdAt?.toIso8601String(),
      };
}
