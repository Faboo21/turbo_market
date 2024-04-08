import 'package:flutter/material.dart';
import 'package:turbo_market/Pages/home_page.dart';
import 'package:turbo_market/pages/ajout_membre_page.dart';
import 'package:turbo_market/pages/choix_jeu_page.dart';
import '../Pages/connexion_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/' :
        return MaterialPageRoute(builder: (context) => const ConnexionPage());
      case '/scan' :
        return MaterialPageRoute(builder: (context) => const ScanPage());
      case '/ajout_user' :
        return MaterialPageRoute(builder: (context) => const UserFormPage());
      case '/choixGames' :
        return MaterialPageRoute(builder: (context) => const GameChoicePage());
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
