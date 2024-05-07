class Level {
  final int gameId;
  int step;
  double cashPrize;
  String libelle;
  int score;

  Level({
    required this.gameId,
    required this.step,
    required this.cashPrize,
    required this.libelle,
    required this.score
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      gameId: int.parse(json['gam_id']),
      step: int.parse(json['lev_step']),
      cashPrize: double.parse(json['lev_cashprize']),
      libelle: json['lev_libelle'] ?? "",
      score: int.parse(json['lev_score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gam_id': gameId,
      'lev_step': step,
      'lev_cashprize': cashPrize,
      'lev_libelle': libelle,
      'lev_score': score,
    };
  }
}