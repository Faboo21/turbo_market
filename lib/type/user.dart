class User {
  int id;
  String username;
  String email;
  double balance;
  String qr;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.balance,
    required this.qr,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['usr_id']),
      username: json['usr_username'],
      email: json['usr_email'],
      balance: double.parse(json['usr_balance']),
      qr: json['usr_qr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usr_id': id,
      'usr_username': username,
      'usr_email': email,
      'usr_balance': balance,
      'usr_qr': qr,
    };
  }
}