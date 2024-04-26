class Level {
  final int gameId;
  int step;
  double cashPrize;
  String libelle;

  Level({
    required this.gameId,
    required this.step,
    required this.cashPrize,
    required this.libelle
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      gameId: int.parse(json['gam_id']),
      step: int.parse(json['lev_step']),
      cashPrize: double.parse(json['lev_cashprize']),
      libelle: json['lev_libelle'] ?? "",
    );
  }
}