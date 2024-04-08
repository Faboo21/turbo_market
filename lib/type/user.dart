class User {
  final int id;
  final String username;
  final String email;
  final int balance;
  final String nfc;
  final int titleId;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.balance,
    required this.nfc,
    required this.titleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['usr_id']),
      username: json['usr_username'],
      email: json['usr_email'],
      balance: int.parse(json['usr_balance']),
      nfc: json['usr_nfc'],
      titleId: int.parse(json['tit_id']),
    );
  }
}