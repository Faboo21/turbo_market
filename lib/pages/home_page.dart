import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/game.dart';
import 'package:turbo_market/type/user.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? scannedNfcId;
  User? scannedNfcUser;
  bool isScanning = false;
  late int role = 0;
  late Game game = Game(id: 0, name: "Chargement", rules: "rules", createdAt: "createdAt", price: 1000000000000);

  @override
  void initState() {
    super.initState();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (role == 3)
              Text("Jeu : ${game.name}, Prix : ${game.price.toString()}"),
            if (scannedNfcId != null)
              Text('Scanned NFC ID: $scannedNfcId'),
            if (scannedNfcUser != null)
              Column(
                children: [
                  Text('Tag de ${scannedNfcUser?.username}'),
                  Text("Solde : ${scannedNfcUser?.balance.toString()}")
                ],
              ),
            if (scannedNfcUser == null && scannedNfcId != null)
              const Text("Tag NFC non attribué"),
            if (scannedNfcUser != null && role == 3)
              Column (
                children: [
                  ElevatedButton(
                    onPressed: scannedNfcUser!.balance >= game.price ? () async {
                      if (await updateUserBalance(scannedNfcUser!, scannedNfcUser!.balance-game.price)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Solde mis à jour avec succès"),
                        ));
                        scannedNfcUser = null;
                        scannedNfcId = null;
                        if (isScanning) _toggleNFCReading();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Probleme lors de la mise à jour du solde"),
                        ));
                      }
                    } : null,
                    child: const Text("Décrémenter le compte")
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/reward");
                    },
                    child: const Text("Augmenter le compte")
                  )
                ],
              )
          ],
        ),
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
              icon: isScanning ? const Icon(Icons.stop) : Image.asset('images/logo-obsolete-noir.png', fit: BoxFit.cover,),
              onPressed: _toggleNFCReading,
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

  void _toggleNFCReading() async {
    if (isScanning) {
      _stopNFCReading();
    } else {
      _startNFCReading();
    }
  }

  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        setState(() {
          isScanning = true;
        });
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            List<int>? identifier = tag.data['nfca']?['identifier'];

            if (identifier != null) {
              String tagId = identifier.map((byte) => byte.toRadixString(16)).join('');
              getUserByNfc(tagId).then((scannedUser) {
                setState(() {
                  scannedNfcId = tagId;
                  scannedNfcUser = scannedUser;
                });
              });
            }
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("NFC non disponible"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Erreur de lecture NFC"),
      ));
    }
  }

  void _stopNFCReading() {
    setState(() {
      isScanning = false;
    });

    NfcManager.instance.stopSession();
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
