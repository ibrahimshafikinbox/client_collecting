class Customer {
  int? id;
  String? name;
  String? address;

  Customer({this.id, this.name, this.address});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as int?,
        name: json['name'] as String?,
        address: json['address'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
      };
}
