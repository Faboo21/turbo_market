import 'package:flutter/material.dart';
import 'package:turbo_market/dialogs/update_exchange_rate_dialoq.dart';
import '../dialogs/password_dialog.dart';

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
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const ChangePasswordDialog();
                      },
                    );
                  },
                  child: const Text("Gestion des Mots de passe")
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/manage_users");
                  },
                  child: const Text("Gestion des Utilisateurs")
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/manage_games");
                  },
                  child: const Text("Gestion des Jeux")
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/manage_prizes");
                  },
                  child: const Text("Gestion des prix")
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const UpdateRateDialog();
                      },
                    );
                  },
                  child: const Text("Changer le Taux de change")
              ),
            ],
          ),
        ));
  }
}