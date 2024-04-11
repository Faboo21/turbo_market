import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  int selectedButtonIndex = 0;
  List<String> accountTypes = ["Admin", "Banquier", "Membre"];
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Connexion"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.asset('images/logo-obsolete-noir.png', fit: BoxFit.cover,),
            ListView.builder(
              shrinkWrap: true,
              itemCount: accountTypes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    onPressed: selectedButtonIndex == index ? null : () {
                      setState(() {
                        selectedButtonIndex = index;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedButtonIndex == index ? Colors.grey : null,
                    ),
                    child: Text(accountTypes[index]),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Champ de mot de passe
            TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Bouton de connexion
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary),
              ),
              onPressed: () {
                final currentContext = context;
                verifyPassword(selectedButtonIndex+1, password).then((isAuthenticated) async {
                  if (mounted) {
                    if (isAuthenticated) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setInt("tea_id",selectedButtonIndex + 1);
                      prefs.setString("date",DateTime.now().toString());
                      if (selectedButtonIndex + 1 == 3) {
                        Navigator.pushNamed(currentContext, '/choixGames');
                      } else {
                        Navigator.pushNamed(currentContext, '/home');
                      }
                    } else {
                      showDialog(
                        context: currentContext,
                        builder: (context) => AlertDialog(
                          title: const Text('Erreur'),
                          content: const Text('Identifiants invalides.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                });
              },

              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
