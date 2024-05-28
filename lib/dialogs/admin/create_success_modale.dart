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
      newSuccess = Success(id: 0, libelle: "libelle", image: "", rarity: temp.first, condition: "return false;", rules: "rules", losable: true, type: 0);
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
                Row(
                  children: [
                    const Text("Succès perdable : "),
                    Checkbox(
                      onChanged: (value) {setState(() {
                        newSuccess.losable = value ?? true;
                      });},
                      value: newSuccess.losable,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<int>(
                  value: newSuccess.type,
                  onChanged: (newValue) {
                    setState(() {
                      newSuccess.type = newValue ?? 0;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 0, child: Text("Tout"),),
                    DropdownMenuItem(value: 1, child: Text("Partie"),),
                    DropdownMenuItem(value: 2, child: Text("Lots"),),
                    DropdownMenuItem(value: 3, child: Text("Jamais"),),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez choisir un type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                if (imageChanged)
                  newSuccess.rarity.id != rarities.last.id ? Center(
                    child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius
                                .circular(500),
                            child: Container(
                              width: 300,
                              height: 300,
                              color: newSuccess.rarity.displayColor,
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: Center(
                              child: SizedBox(
                                width: 200,
                                child:
                                Image.network(
                                  "https://obsolete-events.com/turbo-market/app/images/titles/temp?random=${DateTime.now().millisecondsSinceEpoch}",
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),
                          ),
                        ]
                    ),
                  ) :
                  Center(
                    child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius
                                .circular(500),
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.orange,
                                    Colors.yellow,
                                    Colors.green,
                                    Colors.blue,
                                    Colors.indigo,
                                    Colors.purple,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: Center(
                              child: SizedBox(
                                width: 200,
                                child:
                                Image.network(
                                  "https://obsolete-events.com/turbo-market/app/images/titles/temp?random=${DateTime.now().millisecondsSinceEpoch}",
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),
                          ),
                        ]
                    ),
                  ),
                const SizedBox(height: 15,),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _pickImageFromGallery,
                        child: const Text('Choisir depuis la galerie'),
                      ),
                      const SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () async {
                          dynamic res = await Navigator.pushNamed(context, "/ide", arguments: newSuccess);
                          if (res is String) {
                            newSuccess.condition = res;
                          }
                        },
                        child: const Text("Ouvrir l'IDE"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (imageChanged == true) {
                        insertSuccess(
                            newSuccess
                        ).then((success) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Succès créé avec succès')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  'Erreur lors de la création du succès')),
                            );
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ajoutez une image')),
                        );
                      }
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
