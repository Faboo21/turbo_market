class Transaction {
  int usrId;
  int priId;
  String traTime;
  double traAmount;
  int payId;


  Transaction({
    required this.usrId,
    required this.priId,
    required this.traTime,
    required this.traAmount,
    required this.payId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      usrId: int.parse(json['usr_id']),
      priId: int.tryParse(json['pri_id'] ?? "") ?? 0,
      traTime: json['tra_time'],
      traAmount: double.parse(json['tra_amount']),
      payId: int.tryParse(json['pay_id'] ?? "") ?? 0,
    );
  }
}