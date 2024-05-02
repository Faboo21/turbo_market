import 'package:turbo_market/type/rarity.dart';
import 'package:dart_eval/dart_eval.dart';

class UserTitle {
  final int id;
  String libelle;
  String color;
  String image;
  Rarity rarity;
  String condition;

  UserTitle({
    required this.id,
    required this.libelle,
    required this.color,
    required this.image,
    required this.rarity,
    required this.condition
  });

  bool evaluate() {
    return eval(condition, function: 'check');
  }
}