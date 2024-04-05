import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? scannedNfcId;
  bool isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Scan NFC"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (scannedNfcId != null)
              Text('Scanned NFC ID: $scannedNfcId'),
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
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary)),
              child: const Text('LogOut'),
            ),
            ElevatedButton(
              onPressed: () {
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
      setState(() {
        isScanning = true;
      });

      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            List<int>? identifier = tag.data['nfca']?['identifier'];

            if (identifier != null) {
              String tagId = identifier.map((byte) => byte.toRadixString(16))
                  .join('');
              setState(() {
                scannedNfcId = tagId;
              });
            }
          },
        );
      } else {
        debugPrint('NFC not available.');
      }
    } catch (e) {
      debugPrint('Error reading NFC: $e');
    }
  }

  void _stopNFCReading() {
    setState(() {
      isScanning = false;
      scannedNfcId = null;
    });

    NfcManager.instance.stopSession();
  }
}
