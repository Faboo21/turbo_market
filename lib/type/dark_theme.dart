import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  primaryColor: Colors.black,
  fontFamily: 'Heavitas',
  colorScheme: const ColorScheme(
    primary: Colors.black,
    secondary: Colors.white,
    surface: Colors.black,
    surfaceContainer: Colors.white12,
    surfaceContainerHighest: Colors.white12,
    surfaceContainerHigh: Colors.white12,
    surfaceContainerLow: Colors.white12,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onError: Colors.white,
    brightness: Brightness.dark,
    primaryContainer: Colors.black,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
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
    selectionColor: Colors.white24,
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.grey[900],
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return const TextStyle(color: Colors.white, fontFamily: "Heavitas");
        }
        return const TextStyle(color: Colors.black, fontFamily: "Heavitas");
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.white;
        }
        return Colors.black;
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.black;
        }
        return Colors.white;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
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