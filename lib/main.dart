import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Turbo Market',
      initialRoute: initialRoute,
      onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
                  return Colors.white; // Par exemple, blanc
                }
                return Colors.white; // Par exemple, blanc
              },
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white, fontFamily: "Nexa"),
          fillColor: Colors.grey[800],
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
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