class UsersSuccess {
  int usrId;
  int titId;
  String time;

  UsersSuccess({
    required this.usrId,
    required this.titId,
    required this.time,
  });

  factory UsersSuccess.fromJson(Map<String, dynamic> json) {
    return UsersSuccess(
      usrId: int.parse(json['usr_id']),
      titId: int.parse(json['tit_id']),
      time: json['date'],
    );
  }
}