class Game {
  int id;
  String name;
  String rules;
  String createdAt;
  double price;
  int nbPlayersMin;
  int nbPlayersMax;
  String image;


  Game({
    required this.id,
    required this.name,
    required this.rules,
    required this.createdAt,
    required this.price,
    required this.nbPlayersMin,
    required this.nbPlayersMax,
    required this.image,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: int.parse(json['gam_id']),
      name: json['gam_name'],
      rules: json['gam_rules'],
      createdAt: json['gam_created_at'],
      price: double.parse(json['gam_price']),
      nbPlayersMin : int.parse(json['gam_min_players']),
      nbPlayersMax : int.parse(json['gam_max_players']),
      image : json['gam_image'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gam_id': id.toString(),
      'gam_name': name.toString(),
      'gam_rules': rules.toString(),
      'gam_created_at': createdAt.toString(),
      'gam_price': price.toString(),
      'gam_min_players': nbPlayersMin.toString(),
      'gam_max_players': nbPlayersMax.toString(),
      'gam_image': image.toString(),
    };
  }
}