class Transaction {
  int traId;
  int usrId;
  int priId;
  String traTime;
  double traAmount;
  int payId;


  Transaction({
    required this.traId,
    required this.usrId,
    required this.priId,
    required this.traTime,
    required this.traAmount,
    required this.payId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      traId: int.parse(json['tra_id']),
      usrId: int.parse(json['usr_id']),
      priId: int.tryParse(json['pri_id'] ?? "") ?? 0,
      traTime: json['tra_time'],
      traAmount: double.parse(json['tra_amount']),
      payId: int.tryParse(json['pay_id'] ?? "") ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tra_id': traId.toString(),
      'usr_id': usrId.toString(),
      'pri_id': priId.toString(),
      'tra_time': traTime.toString(),
      'tra_amount': traAmount.toString(),
      'pay_id': payId.toString(),
    };
  }
}