import 'package:flutter/material.dart';

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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Connexion"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.asset('images/logo-obsolete-noir.png', fit: BoxFit.cover,width: 500,),
            ListView.builder(
              shrinkWrap: true,
              itemCount: accountTypes.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: selectedButtonIndex == index ? null : () {
                    setState(() {
                      selectedButtonIndex = index;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedButtonIndex == index ? Colors.grey : null,
                  ),
                  child: Text(accountTypes[index]),
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
                  backgroundColor:
                  MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary)
              ),
              onPressed: () {

              },
              child: const Text('Se connecter'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/scan");
              },
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary)),
              child: const Text('Page Scan'),
            ),
          ],
        ),
      ),
    );
  }
}
