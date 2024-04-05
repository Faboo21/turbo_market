import 'package:flutter/material.dart';
import 'Router/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getInt("tea_id") != null) {
    String? savedDate = prefs.getString("date");
    if (savedDate != null) {
      DateTime lastLoginDate = DateTime.parse(savedDate);
      DateTime now = DateTime.now();
      Duration difference = now.difference(lastLoginDate);
      if (difference.inHours >= 24) {
        prefs.remove("tea_id");
        prefs.remove("date");
      }
    }
  }
  String route = prefs.getInt("tea_id") != null ? "/scan" : "/";
  runApp(MyApp(initialRoute: route,));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turbo Market',
      initialRoute: initialRoute,
      onGenerateRoute: (settings)=> RouteGenerator.generateRoute(settings),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
        useMaterial3: true,
      ),
    );
  }
}