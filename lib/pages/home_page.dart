import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? scannedNfcId;
  String? scannedNfcUsername;
  bool isScanning = false;
  late int role = 1;

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? stockRole = prefs.getInt('tea_id');
    setState(() {
      role = stockRole ?? 3;
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
            if (scannedNfcId != null)
              Text('Scanned NFC ID: $scannedNfcId'),
            if (scannedNfcUsername != null && scannedNfcUsername != "")
              Text('Tag de $scannedNfcUsername'),
            if (scannedNfcUsername != null && scannedNfcUsername == "")
              const Text("Tag NFC non attribué"),
            ElevatedButton(
              onPressed: isScanning ? null : _startNFCReading,
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(
                      !isScanning ? Theme.of(context).colorScheme.inversePrimary : Colors.white10)),
              child: const Text('Start NFC Reading'),
            ),
            ElevatedButton(
              onPressed: isScanning ? _stopNFCReading : null,
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(
                      isScanning ? Theme.of(context).colorScheme.inversePrimary : Colors.white10)),
              child: const Text('Stop NFC Reading'),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('tea_id');
                prefs.remove('date');
                prefs.remove('game_id');
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary)),
              child: const Text('LogOut'),
            ),
            if (role == 2 || role == 1) ElevatedButton(
              onPressed: () async {
                Navigator.pushNamed(context, '/ajout_user');
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary)),
              child: const Text('Ajout d\'utilisateur'),
            ),
          ],
        ),
      ),
    );
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
              String tagId = identifier.map((byte) => byte.toRadixString(16))
                  .join('');
              getUsernameByNfc(tagId).then((scannedUsername) {
                setState(() {
                  scannedNfcId = tagId;
                  scannedNfcUsername = scannedUsername;
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
}
