import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  int selectedButtonIndex = 0;
  List<String> accountTypes = ["Admin", "Banquier", "Bénévole"];
  String password = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Ajoutez un délai simulé pour l'indicateur de chargement
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Connexion"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 600,
            child: ListView(
              children: [
                isLoading ? const SizedBox(
                  height: 300,
                  width: 300,
                  child: Center(child: CircularProgressIndicator())
                ):
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset(
                    'images/logo-obsolete-blanc.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: accountTypes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedButtonIndex = index;
                          });
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 30,),
                            Expanded(
                              child: Text(
                                accountTypes[index],
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (selectedButtonIndex == index) const Icon(Icons.check, color: Colors.black,size: 30,),
                            if (selectedButtonIndex != index) const SizedBox(width: 30,)
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(fontFamily: "Nexa"),
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  onSubmitted: logIn,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: password != "" ? () {logIn("");} : null,

                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void logIn (String s) {
    verifyPassword(selectedButtonIndex + 1, password).then((
        isAuthenticated) async {
      if (mounted) {
        if (isAuthenticated != "") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("token", isAuthenticated);
          AppConfig.role = selectedButtonIndex + 1;
          if (selectedButtonIndex + 1 == 3) {
            Navigator.pushNamed(context, '/choixGames');
          } else {
            Navigator.pushNamed(context, '/home');
          }
        } else {
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
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
  }
}
