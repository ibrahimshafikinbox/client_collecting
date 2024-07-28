class Address {
  int? id;
  String? area;

  Address({this.id, this.area});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as int?,
        area: json['area'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'area': area,
      };
}
