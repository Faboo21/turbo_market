class StatsPlay {
  final int gameid;
  final int levStep;
  final String parTime;
  final double gain;
  final int userId;
  final int score;

  StatsPlay({
    required this.gameid,
    required this.levStep,
    required this.parTime,
    required this.gain,
    required this.userId,
    required this.score,
  });

  factory StatsPlay.fromJson(Map<String, dynamic> json) {
    return StatsPlay(
      gameid: int.parse(json['gam_id']),
      levStep: int.parse(json['lev_step']),
      parTime: json['par_time'],
      gain: double.parse(json['gain']),
      userId: int.parse(json['usr_id']),
      score: int.parse(json['lev_score'])
    );
  }
}