class StatsPlay {
  final int playId;
  final int gameid;
  final int levStep;
  final String parTime;
  final double gain;
  final int userId;
  final int score;
  final int cluster;

  StatsPlay({
    required this.playId,
    required this.gameid,
    required this.levStep,
    required this.parTime,
    required this.gain,
    required this.userId,
    required this.score,
    required this.cluster,
  });

  factory StatsPlay.fromJson(Map<String, dynamic> json) {
    return StatsPlay(
      playId: int.parse(json['pla_id']),
      gameid: int.parse(json['gam_id']),
      levStep: int.parse(json['lev_step']),
      parTime: json['par_time'],
      gain: double.parse(json['pla_gain']),
      userId: int.parse(json['usr_id']),
      score: int.parse(json['lev_score']),
      cluster: int.parse(json['pla_cluster']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playId': playId.toString(),
      'gam_id': gameid.toString(),
      'lev_step': levStep.toString(),
      'par_time': parTime.toString(),
      'gain': gain.toString(),
      'usr_id': userId.toString(),
      'lev_score': score.toString(),
      'pla_cluster': cluster.toString()
    };
  }
}