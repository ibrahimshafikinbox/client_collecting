class LoginModel {
  int? id;
  String? username;
  String? email;
  String? token;
  bool? isSuperuser;
  int? amount;

  LoginModel({
    this.id,
    this.username,
    this.email,
    this.token,
    this.isSuperuser,
    this.amount,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        id: json['id'] as int?,
        username: json['username'] as String?,
        email: json['email'] as String?,
        token: json['token'] as String?,
        isSuperuser: json['is_superuser'] as bool?,
        amount: json['amount'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'token': token,
        'is_superuser': isSuperuser,
        'amount': amount,
      };
}
