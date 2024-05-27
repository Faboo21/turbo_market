import 'package:flutter/material.dart';
import 'package:turbo_market/Pages/home_page.dart';
import 'package:turbo_market/pages/admin_page/code_editor_page.dart';
import 'package:turbo_market/pages/admin_page/management_page/manage_rarity_page.dart';

import '../pages/admin_page/admin_page.dart';
import '../pages/admin_page/historic_page.dart';
import '../pages/admin_page/management_page/manage_game_page.dart';
import '../pages/admin_page/management_page/manage_level_page.dart';
import '../pages/admin_page/management_page/manage_payment_method_page.dart';
import '../pages/admin_page/management_page/manage_prize_page.dart';
import '../pages/admin_page/management_page/manage_success_page.dart';
import '../pages/admin_page/management_page/manage_user_page.dart';
import '../pages/admin_page/stats_page.dart';
import '../pages/bank_page/add_member_page.dart';
import '../pages/bank_page/manage_balance_page.dart';
import '../pages/bank_page/prizes_page.dart';
import '../pages/connexion_page.dart';
import '../pages/guest_page/guest_page.dart';
import '../pages/guest_page/showcase_page.dart';
import '../pages/guest_page/success_page.dart';
import '../pages/game_choice_page.dart';
import '../pages/volunteer_page/reward_page.dart';
import '../pages/volunteer_page/winner_page.dart';
import '../type/api_type/game.dart';
import '../type/api_type/success.dart';
import '../type/api_type/user.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/' :
        return MaterialPageRoute(builder: (context) => const GuestPage());
      case '/showcase' :
        return MaterialPageRoute(builder: (context) => const ShowcasePage());
      case '/connexion' :
        return MaterialPageRoute(builder: (context) => const ConnexionPage());
      case '/home' :
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/ajout_user' :
        return MaterialPageRoute(builder: (context) => const UserFormPage());
      case '/ide' :
        if (args is List<String>) {
          return MaterialPageRoute(builder: (context) => CodeEditorPage(variables: args.sublist(1), code: args[0]));
        }
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/choixGames' :
        return MaterialPageRoute(builder: (context) => const GameChoicePage());
      case '/success' :
        if (args is List<Success>) {
          return MaterialPageRoute(builder: (context) => SuccessPage(success: args,));
        }
        return MaterialPageRoute(builder: (context) => const GuestPage());
      case '/admin' :
        return MaterialPageRoute(builder: (context) => const AdminPage());
      case '/stats' :
        return MaterialPageRoute(builder: (context) => const StatsPage());
      case '/prizes' :
        if (args is User) {
          return MaterialPageRoute(builder: (context) => PrizesPage(selectedUser: args,));
        }
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/manage_levels' :
        if (args is Game) {
          return MaterialPageRoute(builder: (context) => LevelManagementPage(game: args,));
        }
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/manage_users' :
        return MaterialPageRoute(builder: (context) => const UserManagementPage());
      case '/manage_success' :
        return MaterialPageRoute(builder: (context) => const SuccessManagementPage());
      case '/manage_payment_method' :
        return MaterialPageRoute(builder: (context) => const PaymentMethodManagementPage());
      case '/manage_games' :
        return MaterialPageRoute(builder: (context) => const GameManagementPage());
      case '/manage_rarities' :
        return MaterialPageRoute(builder: (context) => const RarityManagementPage());
      case '/manage_prizes' :
        return MaterialPageRoute(builder: (context) => const PrizeManagementPage());
      case '/historic' :
        return MaterialPageRoute(builder: (context) => const HistoricPage());
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
      case '/reward_multi' :
        if (args is User) {
          return MaterialPageRoute(builder: (context) => RewardPage(selectedUser: args, multiPlayers: true,));
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
