class PaymentMethod {
  final int payId;
  String libelle;

  PaymentMethod({
    required this.payId,
    required this.libelle
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      payId: int.parse(json['pay_id']),
      libelle: json['pay_libelle'] ?? "",
    );
  }
}