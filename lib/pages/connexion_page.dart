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
  List<String> accountTypes = ["Bénévole", "Banquier", "Admin"];
  String password = '';
  bool isLoading = true;
  bool btnLoading = false;

  @override
  void initState() {
    super.initState();
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
        leading: IconButton(onPressed: () {Navigator.pushReplacementNamed(context, '/');}, icon: const Icon(Icons.arrow_back),),
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
                  onSubmitted: (s) {logIn();},
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                !btnLoading ? ElevatedButton(
                  onPressed: password != "" ? () {logIn();} : null,
                  child: const Text('Se connecter'),
                ) : const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void logIn () {
    setState(() {
      btnLoading = true;
    });
    verifyPassword(3 - selectedButtonIndex, password).then((
        isAuthenticated) async {
      if (mounted) {
        if (isAuthenticated != "") {
          if (isAuthenticated == "cors") {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Probleme CORS : vérifier lien")));
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("token", isAuthenticated);
            AppConfig.token = isAuthenticated;
            AppConfig.role = 3 - selectedButtonIndex;
            if (3 - selectedButtonIndex == 3) {
              Navigator.pushReplacementNamed(context, '/choixGames');
            } else {
              Navigator.pushNamed(context, '/home');
            }
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
      setState(() {
        btnLoading = false;
      });
    });
  }
}
