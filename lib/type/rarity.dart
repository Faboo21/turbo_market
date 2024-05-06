import 'package:flutter/material.dart';

enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  mythical,
  legendary,
}

extension RarityExtension on Rarity {
  int get value {
    switch (this) {
      case Rarity.common:
        return 0;
      case Rarity.uncommon:
        return 1;
      case Rarity.rare:
        return 2;
      case Rarity.epic:
        return 3;
      case Rarity.mythical:
        return 4;
      case Rarity.legendary:
        return 5;
    }
  }

  Color get color {
    switch (this) {
      case Rarity.common:
        return Colors.grey;
      case Rarity.uncommon:
        return Colors.lightGreenAccent;
      case Rarity.rare:
        return Colors.blue;
      case Rarity.epic:
        return Colors.purpleAccent;
      case Rarity.mythical:
        return Colors.redAccent;
      case Rarity.legendary:
        return Colors.yellowAccent;
    }
  }

  String get displayString {
    switch (this) {
      case Rarity.common:
        return 'Common';
      case Rarity.uncommon:
        return 'Uncommon';
      case Rarity.rare:
        return 'Rare';
      case Rarity.epic:
        return 'Epic';
      case Rarity.mythical:
        return 'Mythical';
      case Rarity.legendary:
        return 'Legendary';
    }
  }
}

extension StringExtension on String {
  Rarity stringToRarity() {
    switch (toLowerCase()) {
      case 'common':
        return Rarity.common;
      case 'uncommon':
        return Rarity.uncommon;
      case 'rare':
        return Rarity.rare;
      case 'epic':
        return Rarity.epic;
      case 'mythical':
        return Rarity.mythical;
      case 'legendary':
        return Rarity.legendary;
      default:
        throw ArgumentError('Invalid Rarity string');
    }
  }
}
