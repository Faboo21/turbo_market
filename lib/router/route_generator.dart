import 'package:flutter/material.dart';
import 'package:turbo_market/Pages/scan_page.dart';
import '../Pages/connexion_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/' :
        return MaterialPageRoute(builder: (context) => const ConnexionPage());
      case '/scan' :
        return MaterialPageRoute(builder: (context) => const ScanPage());
      default :
        return MaterialPageRoute(builder: (context) =>
            Scaffold(
              appBar: AppBar(title: const Text("Error"),centerTitle:true,backgroundColor: Theme.of(context).colorScheme.error),
              body: const Center(
                child: Text('Page not found'),
              ),
            )
        );
    }
  }
}