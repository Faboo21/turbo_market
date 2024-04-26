import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/dialogs/update_exchange_rate_dialoq.dart';
import '../dialogs/password_dialog.dart';
import '../type/user.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  double total = 0;

  @override
  void initState() {
    loadTotal();
    super.initState();
  }

  void loadTotal() async {
    double resTotal = 0;
    List<User> resList = await getAllUsers();
    for (var element in resList) {
      resTotal += element.balance;
    }
    setState(() {
      total = resTotal;
    });
  }

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
              Center(child: Text("Argent en circulation : $total€", style: const TextStyle(fontSize: 20,),)),
              const SizedBox(height: 8.0),
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
                title: const Text("Gestion des Mots de passe")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/manage_users");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.supervised_user_circle),
                  title: const Text("Gestion des Utilisateurs")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/manage_games");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.videogame_asset),
                  title: const Text("Gestion des Jeux")
              ),
              const Divider(),
              ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, "/manage_prizes");
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text("Gestion des prix")
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
                  title: const Text("Changer le Taux de change")
              ),
              const Divider(),
            ],
          ),
        ));
  }
}