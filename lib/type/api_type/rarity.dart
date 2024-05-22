import 'dart:ui';

class Rarity {
  final int id;
  String libelle;
  int value;
  String color;

  Rarity({
    required this.id,
    required this.libelle,
    required this.value,
    required this.color,
  });

  Color get displayColor {
    return Color(int.parse(color));
  }

  factory Rarity.fromJson(Map<String, dynamic> json) {
    return Rarity(
      id: int.parse(json['rar_id']),
      libelle: json['rar_libelle'],
      value: int.parse(json['rar_value']),
      color: json['rar_color'],
    );
  }

  @override
  String toString() {
    return libelle;
  }
}