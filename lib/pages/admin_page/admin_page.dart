import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:turbo_market/dialogs/admin/password_dialog.dart';
import 'package:turbo_market/dialogs/admin/update_exchange_rate_dialoq.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/stats");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.query_stats),
                  title: const Text("Stats")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/accountancy");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.account_balance),
                  title: const Text("Bilan")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/historic");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.history),
                  title: const Text("Historique")
              ),
              const Divider(),
              ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ChangePasswordDialog();
                    },
                  );
                },
                trailing: const Icon(Icons.arrow_forward_ios),
                leading: const Icon(Icons.lock_person),
                title: const Text("Mots de passe")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/manage_success");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(FontAwesome.award),
                  title: const Text("Succès")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/manage_users");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.supervised_user_circle),
                  title: const Text("Utilisateurs")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/manage_games");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.videogame_asset),
                  title: const Text("Jeux")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/manage_prizes");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text("Prix")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/manage_rarities");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(FontAwesome.star),
                  title: const Text("Raretés")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/manage_payment_method");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.credit_card),
                  title: const Text("Modes de paiement")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const UpdateRateDialog();
                      },
                    );
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.attach_money),
                  title: const Text("Taux de change")
              ),
              const Divider(),
            ],
          ),
        ));
  }
}