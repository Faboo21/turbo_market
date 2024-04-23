class StatsPlay {
  final int gameid;
  final int levStep;
  final String parTime;
  final double gain;


  StatsPlay({
    required this.gameid,
    required this.levStep,
    required this.parTime,
    required this.gain,
  });

  factory StatsPlay.fromJson(Map<String, dynamic> json) {
    return StatsPlay(
      gameid: int.parse(json['gam_id']),
      levStep: int.parse(json['lev_step']),
      parTime: json['par_time'],
      gain: double.parse(json['gain']),
    );
  }
}