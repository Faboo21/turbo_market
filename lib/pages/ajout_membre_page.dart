import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:turbo_market/api/api_request.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  String? scannedNfcId;
  bool isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajout d\'un utilisateur'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Merci d\'entrer un pseudo';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Pseudo',
                ),
              ),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Merci d\'entrer un email';
                  }
                  if (!value.contains('@')) {
                    return 'Merci d\'entrer un email valide';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: _montantController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Merci d\'entrer une valeur positive';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Merci d\'entrer un entier positive';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                ),
              ),
              Center (child:
                Column (children: [
                  const SizedBox(height: 20),
                  if (scannedNfcId != null)
                    Text('NFC ID: $scannedNfcId'),
                  ElevatedButton(
                    onPressed: isScanning ? null : _startNFCReading,
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            !isScanning ? Theme.of(context).colorScheme.inversePrimary : Colors.white10)),
                    child: const Text('Demarrer le scan NFC'),
                  ),
                  ElevatedButton(
                    onPressed: isScanning ? _stopNFCReading : null,
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            isScanning ? Theme.of(context).colorScheme.inversePrimary : Colors.white10)),
                    child: const Text('Arreter le scan NFC'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _usernameController.text != "" && _emailController.text != "" && _montantController.text != "" && scannedNfcId != null ? () async {
                      if (_formKey.currentState!.validate() && scannedNfcId != null) {
                        String username = _usernameController.text;
                        String email = _emailController.text;
                        int montant = int.parse(_montantController.text);
                        if (await insertUser(username, email, scannedNfcId!, montant)){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Utilisateur ajouté"),
                          ));
                          Navigator.pop(context);
                        }else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Probleme d'insertion : un des paramettres n'est pas unique"),
                          ));
                        }
                      }
                    } : null,
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary)),
                    child: const Text("Valider"),
                  ),
                ])
              )
            ],
          ),
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
              setState(() {
                scannedNfcId = tagId;
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