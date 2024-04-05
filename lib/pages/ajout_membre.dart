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
  String? scannedNfcId;
  bool isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Form'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              Center (child:
                Column (children: [
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _usernameController.text != "" && _emailController.text != "" && scannedNfcId != null ? () {
                      if (_formKey.currentState!.validate() && scannedNfcId != null) {
                        String username = _usernameController.text;
                        String email = _emailController.text;
                        insertUser(username, email, scannedNfcId!);
                      }
                    } : null,
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary)),
                    child: const Text('Submit'),
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