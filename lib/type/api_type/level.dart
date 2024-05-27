class Level {
  final int gameId;
  int step;
  double cashPrize;
  String libelle;
  int score;
  bool active;

  Level({
    required this.gameId,
    required this.step,
    required this.cashPrize,
    required this.libelle,
    required this.score,
    required this.active
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      gameId: int.parse(json['gam_id']),
      step: int.parse(json['lev_step']),
      cashPrize: double.parse(json['lev_cashprize']),
      libelle: json['lev_libelle'] ?? "",
      score: int.parse(json['lev_score']),
      active: int.parse(json['lev_active']) == 1
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gam_id': gameId.toString(),
      'lev_step': step.toString(),
      'lev_cashprize': cashPrize.toString(),
      'lev_libelle': libelle.toString(),
      'lev_score': score.toString(),
      'lev_active': active ? "1" : "0"
    };
  }
}