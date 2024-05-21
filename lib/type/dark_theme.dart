import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  primaryColor: Colors.black,
  fontFamily: 'Heavitas',
  colorScheme: const ColorScheme(
    primary: Colors.black,
    secondary: Colors.white,
    surface: Colors.white12,
    background: Colors.black,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.white;
          }
          return Colors.white;
        },
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(style: BorderStyle.solid, color: Colors.white)),
    labelStyle: const TextStyle(color: Colors.white, fontFamily: "Nexa"),
    fillColor: Colors.grey[800],
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.grey[900],
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.white;
        }
        return Colors.black;
      }),
      backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.black;
        }
        return Colors.white;
      }),
      side: MaterialStateProperty.resolveWith<BorderSide>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return const BorderSide(color: Colors.white, width: 1.0);
        }
        // Pas de bordure pour les autres états du bouton
        return BorderSide.none;
      }),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.white12, // Fond gris pour les Snackbars
    contentTextStyle: TextStyle(color: Colors.white), // Texte blanc pour les Snackbars
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Colors.white, // Couleur des indicateurs de chargement (spinner)
  ),
);