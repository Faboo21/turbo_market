import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:turbo_market/type/api_type/game.dart';

import '../../api/game_request.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rulesController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nbPlayersMinController = TextEditingController();
  final TextEditingController nbPlayersMaxController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool loading = true;

  Future<void> _pickImageFromGallery() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((pickedImage) => {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload en cours"))),
      if (pickedImage != null) {
        uploadGameImageToAPI(pickedImage, "temp").then((value) => {
          setState(() {
            loading = false;
          }),
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image téléversée")))
        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un jeu'),
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
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom du jeu'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer un nom de jeu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: rulesController,
                  decoration: const InputDecoration(labelText: 'Règles'),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer les règles du jeu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Prix', prefixText: "€"),
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  validator: (value) {
                    value = value?.replaceAll(",", ".");
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer le prix du jeu';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Le prix doit être un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: nbPlayersMinController,
                  decoration: const InputDecoration(labelText: 'Nombre de joueurs minimum'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer le nombre minimum de joueurs';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Le nombre minimum de joueurs doit être un entier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: nbPlayersMaxController,
                  decoration: const InputDecoration(labelText: 'Nombre de joueurs maximum'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer le nombre maximum de joueurs';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Le nombre maximum de joueurs doit être un entier';
                    }
                    final nbPlayersMin = int.tryParse(nbPlayersMinController.text);
                    final nbPlayersMax = int.tryParse(value);
                    if (nbPlayersMin != null && nbPlayersMax != null && nbPlayersMax < nbPlayersMin) {
                      return 'Le nombre maximum de joueurs doit être supérieur ou égal au nombre minimum';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                if (!loading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        "https://obsolete-events.com/turbo-market/app/images/games/temp?random=${DateTime.now().millisecondsSinceEpoch}",
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  child: const Text('Ajouter une image'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Game newGame = Game(
                        id: 0,
                        name: nameController.text,
                        rules: rulesController.text,
                        createdAt: "",
                        price: double.parse(priceController.text.replaceAll(",", ".")),
                        nbPlayersMin: int.parse(nbPlayersMinController.text),
                        nbPlayersMax: int.parse(nbPlayersMaxController.text),
                        image: "",
                      );
                      insertGame(newGame).then((res) => {
                        if (res) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jeu ajouté avec succès")))
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Probleme lors de l'insertion du jeu")))
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
    // Dispose les contrôleurs lorsque la page est détruite pour éviter les fuites de mémoire
    nameController.dispose();
    rulesController.dispose();
    priceController.dispose();
    nbPlayersMinController.dispose();
    nbPlayersMaxController.dispose();
    super.dispose();
  }
}
