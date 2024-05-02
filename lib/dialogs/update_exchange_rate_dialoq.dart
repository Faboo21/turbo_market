import "package:flutter/material.dart";
import "package:turbo_market/private/config.dart";

import "../api/api_request.dart";

class UpdateRateDialog extends StatelessWidget {
  const UpdateRateDialog({super.key});

  @override
  Widget build(BuildContext context) {

    final formKey = GlobalKey<FormState>();
    TextEditingController rateController = TextEditingController(text: AppConfig.rate.toString());
    return AlertDialog(
      title: const Text('Taux de change'),
      content: Form(
        key: formKey,
        child : Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextFormField(
              controller: rateController,
              decoration: const InputDecoration(
                labelText: 'Taux de change',
              ),
              validator: (value) {
                if (int.tryParse(value!) == null) {
                  return "Entrez un entier";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(onPressed:() {
          if (formKey.currentState!.validate()){
            updateExchangeRate(int.parse(rateController.text)).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(value
                      ? "Taux changé avec succès"
                      : "Probleme lors du changement du taux")));
              if (value) {
                Navigator.pop(context);
              }
            });
          }
        }, child: const Text("Valider")),
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