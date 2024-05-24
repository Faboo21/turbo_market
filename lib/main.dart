import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/dark_theme.dart';
import 'router/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:turbo_market/api/exchange_rate_request.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");
  if (token != null) {
    AppConfig.token = token;
    Map<String, dynamic> res = await getTokenInfo(token);
    if (res.isNotEmpty) {
      AppConfig.role = int.tryParse(res['tea_id']) ?? 0;
      String savedDate = res['date'];
      DateFormat apiDateFormat = DateFormat("yyyy-MM-dd hh:mm:ss");
      DateTime lastLoginDate = apiDateFormat.parse(savedDate);
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastLoginDate);
      if (difference.inHours >= 24) {
        prefs.remove("token");
        AppConfig.token = "no_key";
      }
    }
  }
  AppConfig.rate = await getExchangeRate();
  AppConfig.banquier = AppConfig.role == 2;
  AppConfig.admin = AppConfig.role == 1;
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
      theme: darkTheme
    );
  }
}