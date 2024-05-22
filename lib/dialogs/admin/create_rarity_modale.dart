import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:turbo_market/api/rarity_request.dart';
import 'package:turbo_market/type/api_type/rarity.dart';

class CreateRarityPage extends StatefulWidget {
  const CreateRarityPage({super.key});

  @override
  State<CreateRarityPage> createState() => _CreateRarityPageState();
}

class _CreateRarityPageState extends State<CreateRarityPage> {
  final TextEditingController libelleController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  Color selectedColor = Colors.white;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une rareté'),
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
                TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: 'Valeur'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer la valeur';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Merci d\'entrer un entier';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Merci d\'entrer un entier supérieur à 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (value) {
                      selectedColor = value;
                    }
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Rarity newRarity = Rarity(
                        libelle: libelleController.text, id: 0, value: int.parse(valueController.text), color: "0x${selectedColor.toHexString()}",
                      );
                      insertRarity(newRarity).then((success) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rareté ajouté avec succès")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème lors de l'ajout de la rareté")));
                        }
                        Navigator.pop(context);
                      });
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
