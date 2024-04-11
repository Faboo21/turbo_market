class Game {
  final int id;
  final String name;
  final String rules;
  final String createdAt;
  final int price;
  final int nbPlayers;

  Game({
    required this.id,
    required this.name,
    required this.rules,
    required this.createdAt,
    required this.price,
    required this.nbPlayers
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: int.parse(json['gam_id']),
      name: json['gam_name'],
      rules: json['gam_rules'],
      createdAt: json['gam_created_at'],
      price: int.parse(json['gam_price']),
      nbPlayers : int.parse(json['gam_nb_players'])
    );
  }
}