import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import '../type/prize.dart';
import 'package:image_picker/image_picker.dart';


class CreatePrizePage extends StatefulWidget {
  const CreatePrizePage({super.key});

  @override
  State<CreatePrizePage> createState() => _CreatePrizePageState();
}

class _CreatePrizePageState extends State<CreatePrizePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = true;

  Future<void> _pickImageFromGallery() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((pickedImage) => {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload en cours"))),
      if (pickedImage != null) {
        uploadPrizeImageToAPI(pickedImage, "temp").then((value) => {
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
        title: const Text('Créer un prix'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom du prix'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un nom pour le prix';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer une description pour le prix';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Prix', prefixText: "€"),
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                validator: (value) {
                  value = value?.replaceAll(",", ".");
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un prix pour le prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Le prix doit être un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le stock pour le prix';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Le stock doit être un entier';
                  }
                  return null;
                },
              ),
              if (!loading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      "https://obsolete-events.com/turbo-market/app/images/prizes/temp?random=${DateTime.now().millisecondsSinceEpoch}",
                      height: 200, // Hauteur maximale de l'image
                      fit: BoxFit.cover, // Ajustement de la taille de l'image pour couvrir les dimensions spécifiées
                    ),
                  ),
                ),
              const SizedBox(height: 15,),
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: const Text('Choisir depuis la galerie'),
              ),
              const SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      insertPrize(
                        Prize(
                          id: 0,
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text.replaceAll(",", ".")),
                          stock: int.parse(stockController.text),
                          createdAt: '',
                          image: '',
                        ),
                      ).then((success) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Prix créé avec succès')),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Erreur lors de la création du prix')),
                          );
                        }
                      });
                    }
                  },
                  child: const Text('Créer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
