import 'package:flutter/material.dart';
import '../api/api_request.dart';

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
                    return 'Merci d\'entrer un entier positif';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String username = _usernameController.text;
                    String email = _emailController.text;
                    int montant = int.parse(_montantController.text);

                    if (await insertUser(username, email, montant)){
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
                },
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary)),
              child: const Text("Valider"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}