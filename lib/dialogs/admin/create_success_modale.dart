import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turbo_market/type/api_type/rarity.dart';
import 'package:turbo_market/type/api_type/success.dart';
import 'package:turbo_market/api/rarity_request.dart';
import 'package:turbo_market/api/success_request.dart';


class CreateSuccessPage extends StatefulWidget {
  const CreateSuccessPage({super.key});

  @override
  State<CreateSuccessPage> createState() => _CreateSuccessPageState();
}

class _CreateSuccessPageState extends State<CreateSuccessPage> {
  TextEditingController libelleController = TextEditingController();
  TextEditingController rulesController = TextEditingController();
  TextEditingController conditionController = TextEditingController();


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool imageChanged = false;
  List<Rarity> rarities = [];
  late Success newSuccess;

  @override
  void initState() {
    loadRarities().then((value) => super.initState());
  }

  Future<void> loadRarities() async {
    List<Rarity> temp = await getAllRarities();
    setState(() {
      rarities = temp;
      newSuccess = Success(id: 0, libelle: "libelle", image: "", rarity: temp.first, condition: "condition", rules: "rules");
    });
  }

  Future<void> _pickImageFromGallery() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((pickedImage) => {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload en cours"))),
      if (pickedImage != null) {
        uploadSuccessImageToAPI(pickedImage, "temp").then((value) => {
          setState(() {
            imageChanged = true;
            newSuccess.image = "true";
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
        title: const Text('Créer un succès'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                TextFormField(
                  controller: libelleController,
                  onChanged: (value) => newSuccess.libelle = value,
                  decoration: const InputDecoration(labelText: 'Nom du succès'),
                  validator:  (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer le nom du succès';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: rulesController,
                  onChanged: (value) => newSuccess.rules = value,
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
                  onChanged: (value) => newSuccess.condition = value,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Merci d\'entrer les conditions du succès';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<Rarity>(
                  value: newSuccess.rarity,
                  onChanged: (Rarity? newValue) {
                    setState(() {
                      newSuccess.rarity = newValue!;
                    });
                  },
                  items: rarities.map((Rarity rarity) {
                    return DropdownMenuItem<Rarity>(
                      value: rarity,
                      child: Text(rarity.libelle, style: TextStyle(color: rarity.displayColor),),
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
                if (!imageChanged && newSuccess.image != "")
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            "${newSuccess.image}?random=${DateTime.now().millisecondsSinceEpoch}",
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
                      ///newSuccess.evaluate(User(id: 0, username: "username", email: "email", balance: 0, qr: "qr"));
                    } catch (e) {
                      compile = false;
                    }
                    if (_formKey.currentState!.validate() && imageChanged == true) {
                      if (compile) {
                        insertSuccess(
                          newSuccess
                        ).then((success) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Succès créé avec succès')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Erreur lors de la création du succès')),
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
