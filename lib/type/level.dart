class Level {
  final int gameId;
  final int step;
  final double cashPrize;

  Level({
    required this.gameId,
    required this.step,
    required this.cashPrize,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      gameId: int.parse(json['gam_id']),
      step: int.parse(json['lev_step']),
      cashPrize: double.parse(json['lev_cashprize']),
    );
  }
}