import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'Router/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");
  if (token != null) {
    Map<String, dynamic> res = await getTokenInfo(token);
    AppConfig.role = int.tryParse(res['tea_id'])!;
    String savedDate = res['date'];
    DateFormat apiDateFormat = DateFormat("yyyy-MM-dd hh:mm:ss");
    DateTime lastLoginDate = apiDateFormat.parse(savedDate);
    DateTime now = DateTime.now();
    Duration difference = now.difference(lastLoginDate);
    if (difference.inHours >= 24) {
      prefs.remove("token");
    }
  }
  AppConfig.taux = await getExchangeRate();
  String initialRoute = AppConfig.role == 0 ? "/" : AppConfig.role == 3 ? "/choixGames" : "/home";
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turbo Market',
      initialRoute: initialRoute,
      onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        fontFamily: 'Heavitas',
        colorScheme: const ColorScheme(
          primary: Colors.black, // Variante de la couleur principale, peut être utilisée pour des éléments spécifiques
          secondary: Colors.white, // Variante de la couleur secondaire
          surface: Colors.white12, // Couleur de la surface, généralement utilisée pour les arrière-plans de cartes, de panneaux, etc.
          background: Colors.black, // Couleur d'arrière-plan
          error: Colors.red, // Couleur d'erreur
          onPrimary: Colors.white, // Couleur du texte sur la couleur principale
          onSecondary: Colors.black, // Couleur du texte sur la couleur secondaire
          onSurface: Colors.white, // Couleur du texte sur la surface
          onBackground: Colors.white, // Couleur du texte sur l'arrière-plan
          onError: Colors.white, // Couleur du texte sur une erreur
          brightness: Brightness.dark, // Luminosité du thème, définie sur sombre
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.white; // Par exemple, blanc
                }
                return Colors.white; // Par exemple, blanc
              },
            ),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[900], // Couleur de fond de l'AlertDialog
          // Personnalisez d'autres aspects de votre AlertDialog si nécessaire
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
      ),

    );
  }
}