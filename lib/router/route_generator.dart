import 'package:flutter/material.dart';
import 'package:turbo_market/Pages/home_page.dart';
import 'package:turbo_market/pages/add_member_page.dart';
import 'package:turbo_market/pages/game_choice_page.dart';
import 'package:turbo_market/pages/manage_game_page.dart';
import 'package:turbo_market/pages/manage_prize_page.dart';
import 'package:turbo_market/pages/reward_page.dart';
import 'package:turbo_market/pages/connexion_page.dart';
import 'package:turbo_market/pages/admin_page.dart';
import 'package:turbo_market/pages/winner_page.dart';
import 'package:turbo_market/pages/manage_balance_page.dart';
import 'package:turbo_market/type/user.dart';

import '../pages/manage_user_page.dart';
import '../pages/prizes_page.dart';
import '../pages/stats_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/' :
        return MaterialPageRoute(builder: (context) => const ConnexionPage());
      case '/home' :
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/ajout_user' :
        return MaterialPageRoute(builder: (context) => const UserFormPage());
      case '/choixGames' :
        return MaterialPageRoute(builder: (context) => const GameChoicePage());
      case '/admin' :
        return MaterialPageRoute(builder: (context) => const AdminPage());
      case '/stats' :
        return MaterialPageRoute(builder: (context) => const StatsPage());
      case '/prizes' :
        if (args is User) {
          return MaterialPageRoute(builder: (context) => Prizes(selectedUser: args,));
        }
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/manage_users' :
        return MaterialPageRoute(builder: (context) => const UserManagementPage());
      case '/manage_games' :
        return MaterialPageRoute(builder: (context) => const GameManagementPage());
      case '/manage_prizes' :
        return MaterialPageRoute(builder: (context) => const PrizeManagementPage());
      case '/winner' :
        if (args is List<User?>) {
          return MaterialPageRoute(builder: (context) => WinnerChoicePage(playersList: args,));
        }
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/reward' :
        if (args is User) {
          return MaterialPageRoute(builder: (context) => RewardPage(selectedUser: args,));
        }
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/manage_balance' :
        if (args is User) {
          return MaterialPageRoute(builder: (context) => ManageBalance(selectedUser: args,));
        }
        return MaterialPageRoute(builder: (context) => const HomePage());
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
