import 'package:flutter/material.dart';
import 'package:turbo_market/type/api_type/payment_method.dart';
import 'package:turbo_market/api/payment_method_request.dart';

class CreatePaymentMethodPage extends StatefulWidget {
  const CreatePaymentMethodPage({super.key});

  @override
  State<CreatePaymentMethodPage> createState() => _CreatePaymentMethodPageState();
}

class _CreatePaymentMethodPageState extends State<CreatePaymentMethodPage> {
  final TextEditingController libelleController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un mode de paiement'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: libelleController,
                  decoration: const InputDecoration(labelText: 'Libellé'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer un libellé';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      PaymentMethod newPaymentMethod = PaymentMethod(
                        payId: 0, // L'id sera généré automatiquement côté serveur
                        libelle: libelleController.text,
                      );
                      bool success = await insertPaymentMethod(newPaymentMethod);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mode de paiement ajouté avec succès")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème lors de l'ajout du mode de paiement")));
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    libelleController.dispose();
    super.dispose();
  }
}
