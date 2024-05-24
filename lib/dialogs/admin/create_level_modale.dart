import 'package:flutter/material.dart';
import 'package:turbo_market/type/api_type/game.dart';
import 'package:turbo_market/type/api_type/level.dart';
import 'package:turbo_market/api/level_request.dart';

class CreateLevelPage extends StatefulWidget {
  const CreateLevelPage({super.key, required this.game});
  final Game game;

  @override
  State<CreateLevelPage> createState() => _CreateLevelPageState();
}

class _CreateLevelPageState extends State<CreateLevelPage> {
  TextEditingController stepController = TextEditingController();
  TextEditingController libelleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController scoreController = TextEditingController();


  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un niveau'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.game.name),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: stepController,
                  decoration: const InputDecoration(labelText: 'Palier'),
                  validator:  (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer le palier';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Merci d\'entrer un entier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: libelleController,
                  decoration: const InputDecoration(labelText: 'Libelle'),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Recompense', prefixText: "€"),
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  validator: (value) {
                    value = value?.replaceAll(",", ".");
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer la recompense';
                    }
                    if (double.tryParse(value) == null) {
                      return 'La recompense doit être un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: scoreController,
                  decoration: const InputDecoration(labelText: 'Score'),
                  validator:  (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer le score';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Merci d\'entrer un entier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Level newLevel = Level(
                        gameId: widget.game.id,
                        step: int.parse(stepController.text),
                        cashPrize: double.parse(priceController.text.replaceAll(",", ".")),
                        libelle: libelleController.text,
                        score: int.parse(scoreController.text),
                        active: true
                      );
                      insertLevel(newLevel).then((res) => {
                        if (res) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Niveau ajouté avec succès")))
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Probleme lors de l'insertion du niveau")))
                        },
                        Navigator.pop(context)
                      });
                    }
                  },
                  child: const Text('Créer'),
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
    stepController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
