import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/rarity.dart';
import 'package:turbo_market/type/user.dart';
import '../type/title.dart';
import 'package:image_picker/image_picker.dart';


class CreateTitlePage extends StatefulWidget {
  const CreateTitlePage({super.key});

  @override
  State<CreateTitlePage> createState() => _CreateTitlePageState();
}

class _CreateTitlePageState extends State<CreateTitlePage> {
  TextEditingController libelleController = TextEditingController();
  TextEditingController rulesController = TextEditingController();
  TextEditingController conditionController = TextEditingController();

  UserTitle newTitle = UserTitle(id: 0, libelle: "libelle", image: "", rarity: Rarity.common, condition: "condition", rules: "rules");

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool imageChanged = false;

  Future<void> _pickImageFromGallery() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((pickedImage) => {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload en cours"))),
      if (pickedImage != null) {
        uploadTitleImageToAPI(pickedImage, "temp").then((value) => {
          setState(() {
            imageChanged = true;
            newTitle.image = "true";
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
        title: const Text('Créer un titre'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: libelleController,
                  onChanged: (value) => newTitle.libelle = value,
                  decoration: const InputDecoration(labelText: 'Nom du titre'),
                  validator:  (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer le nom du titre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: rulesController,
                  onChanged: (value) => newTitle.rules = value,
                  decoration: const InputDecoration(labelText: 'Regles'),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer les regles';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  style: const TextStyle(fontFamily: "Nexa"),
                  controller: conditionController,
                  onChanged: (value) => newTitle.condition = value,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer les conditions du titre';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<Rarity>(
                  value: newTitle.rarity,
                  onChanged: (Rarity? newValue) {
                    setState(() {
                      newTitle.rarity = newValue ?? Rarity.common;
                    });
                  },
                  items: Rarity.values.map((Rarity rarity) {
                    return DropdownMenuItem<Rarity>(
                      value: rarity,
                      child: Text(rarity.displayString, style: TextStyle(color: rarity.color),),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Rareté',
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez choisir une rareté';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                if (!imageChanged && newTitle.image != "")
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            "${newTitle.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (imageChanged)
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            "https://obsolete-events.com/turbo-market/app/images/titles/temp?random=${DateTime.now().millisecondsSinceEpoch}",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 15,),
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  child: const Text('Choisir depuis la galerie'),
                ),
                const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    bool compile = true;
                    try {
                      newTitle.evaluate(User(id: 0, username: "username", email: "email", balance: 0, qr: "qr"));
                    } catch (e) {
                      compile = false;
                    }
                    if (_formKey.currentState!.validate() && imageChanged == true) {
                      if (compile) {
                        insertTitle(
                          newTitle
                        ).then((success) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Titre créé avec succès')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Erreur lors de la création du titre')),
                            );
                          }
                        });
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Le code ne compile pas')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajoutez une image')),
                      );
                    }
                  },
                  child: const Text('Créer'),
                ),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }
}
