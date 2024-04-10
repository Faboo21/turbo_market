import 'package:flutter/material.dart';
import 'package:turbo_market/Pages/home_page.dart';
import 'package:turbo_market/pages/ajout_membre_page.dart';
import 'package:turbo_market/pages/choix_jeu_page.dart';
import 'package:turbo_market/pages/reward_page.dart';
import '../Pages/connexion_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/' :
        return MaterialPageRoute(builder: (context) => const ConnexionPage());
      case '/home' :
        if (args is String) {
          return MaterialPageRoute(builder: (_) => HomePage(scannedQrId: args));
        }
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/ajout_user' :
        return MaterialPageRoute(builder: (context) => const UserFormPage());
      case '/choixGames' :
        return MaterialPageRoute(builder: (context) => const GameChoicePage());
      case '/reward' :
        return MaterialPageRoute(builder: (context) => const RewardPage());
      default :
        return MaterialPageRoute(builder: (context) =>
            Scaffold(
              appBar: AppBar(title: const Text("Error", ),centerTitle:true,backgroundColor: Theme.of(context).colorScheme.error, automaticallyImplyLeading: false,),
              body: const Center(
                child: Text('Page not found'),
              ),
            )
        );
    }
  }
}
