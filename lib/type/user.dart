class User {
  int id;
  String username;
  String email;
  double balance;
  String qr;
  int titleId;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.balance,
    required this.qr,
    required this.titleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['usr_id']),
      username: json['usr_username'],
      email: json['usr_email'],
      balance: double.parse(json['usr_balance']),
      qr: json['usr_qr'],
      titleId: int.parse(json['tit_id']),
    );
  }
}