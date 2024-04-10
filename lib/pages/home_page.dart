import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/game.dart';
import 'package:turbo_market/type/user.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.scannedQrId});
  final String? scannedQrId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? scannedQrId;
  User? scannedQrUser;
  bool isScanning = false;
  late int role = 0;
  late Game game = Game(id: 0, name: "Chargement", rules: "rules", createdAt: "createdAt", price: 1000000000000);
  String result = '';

  @override
  void initState() {
    super.initState();
    scannedQrId = widget.scannedQrId;
    loadSharedPreferences();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? stockRole = prefs.getInt('tea_id');
    int? stockGame = prefs.getInt('gam_id');
    if (stockGame != null){
      Game getGame = await getGameById(stockGame);
      setState(() {
        game = getGame;
      });
    }
    setState(() {
      role = stockRole!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Turbo Market"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          if (role == 3)
            Text("Jeu : ${game.name}, Prix : ${game.price.toString()}"),
          if (scannedQrId != null)
            Text('Scanned QR ID: $scannedQrId'),
          if (scannedQrUser != null)
            Column(
              children: [
                Text('Tag de ${scannedQrUser?.username}'),
                Text("Solde : ${scannedQrUser?.balance.toString()}")
              ],
            ),
          if (scannedQrUser == null && scannedQrId != null)
            const Text("Tag NFC non attribué"),
          if (scannedQrUser != null && role == 3)
            Column(
              children: [
                ElevatedButton(
                  onPressed: scannedQrUser!.balance >= game.price
                      ? () async {
                    if (await updateUserBalance(
                        scannedQrUser!,
                        scannedQrUser!.balance - game.price)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Solde mis à jour avec succès"),
                        ),
                      );
                      scannedQrUser = null;
                      scannedQrId = null;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Problème lors de la mise à jour du solde"),
                        ),
                      );
                    }
                  }
                      : null,
                  child: const Text("Décrémenter le compte"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/reward");
                  },
                  child: const Text("Augmenter le compte"),
                )
              ],
            )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (role == 2 || role == 1)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  Navigator.pushNamed(context, '/ajout_user');
                },
              ),
            IconButton(
              icon: Image.asset('images/logo-obsolete-noir.png', fit: BoxFit.cover,),
              onPressed: () async {
                var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ));
                setState(() {
                  if (res is String) {
                    scannedQrId = res;
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('tea_id');
                prefs.remove('date');
                prefs.remove('gam_id');
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }
}
