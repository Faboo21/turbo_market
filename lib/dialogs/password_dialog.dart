import "package:flutter/material.dart";

import "../api/api_request.dart";

class ChangePasswordDialog extends StatelessWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController masterPasswordController = TextEditingController();

    List<String> roles = ['Admin', 'Banquier', 'Membre'];
    List<TextEditingController> controllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];

    return AlertDialog(
      title: const Text('Gestion des mots de passe'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: masterPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mot de passe maître',
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < roles.length; i++)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllers[i],
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe ${roles[i]}',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (await updatePassword(masterPasswordController.text, controllers[i].text, i+1)){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mot de passe mis à jour")));
                      controllers[i].text = "";
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Probleme de mise a jour du mot de passe")));
                    }
                  },
                  icon: const Icon(Icons.lock_open),
                ),
              ],
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}