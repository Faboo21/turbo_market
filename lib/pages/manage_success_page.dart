import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/rarity.dart';
import 'package:turbo_market/type/success.dart';
import 'package:turbo_market/type/user.dart';

import '../dialogs/create_success_modale.dart';

class SuccessManagementPage extends StatefulWidget {
  const SuccessManagementPage({super.key});

  @override
  State<SuccessManagementPage> createState() => _SuccessManagementPageState();
}

class _SuccessManagementPageState extends State<SuccessManagementPage> {
  List<Success> successList = [];
  List<Success> filteredSuccessList = [];

  TextEditingController searchController = TextEditingController();
  bool imageChanged = false;
  List<Rarity> rarities = [];

  @override
  void initState() {
    loadSuccess();
    super.initState();
  }

  Future<void> loadSuccess() async {
    List<Rarity> resRarities = await getAllRarities();
    List<Success> resList = await getAllSuccess();
    setState(() {
      rarities = resRarities;
      successList = resList;
      filteredSuccessList = successList;
    });
  }

  void filterSuccess(String query) {
    List<Success> filteredSuccess = successList.where((success) => success.libelle.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredSuccessList = filteredSuccess;
    });
  }

  Future<void> _pickImageFromGallery() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((pickedImage) => {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload en cours"))),
      if (pickedImage != null) {
        uploadSuccessImageToAPI(pickedImage, "temp").then((value) => {
          setState(() {
            imageChanged = true;
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
        title: const Text('Succès'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return const CreateSuccessPage();
            },
          ).then((value) async {
            await loadSuccess();
            filterSuccess(searchController.text);
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterSuccess,
              decoration: const InputDecoration(
                labelText: 'Rechercher par nom du Succès',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSuccessList.length,
              itemBuilder: (context, index) {
                Success success = filteredSuccessList[index];
                TextEditingController libelleController = TextEditingController(text: success.libelle);
                TextEditingController rulesController = TextEditingController(text: success.rules);
                TextEditingController conditionController = TextEditingController(text: success.condition);

                final formKey = GlobalKey<FormState>();
                success.rarity = rarities.firstWhere((element) => element.id == success.rarity.id, orElse: () => rarities.first);

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    leading: SizedBox(
                      width: 50,
                      child: AspectRatio(
                        aspectRatio: 1, // Aspect ratio 1:1 for square image
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    title: Text(success.libelle, style: TextStyle(color: success.rarity.displayColor),),
                    children: [
                      Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: libelleController,
                                onChanged: (value) => success.libelle = value,
                                decoration: const InputDecoration(labelText: 'Nom du Succès'),
                                validator:  (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le nom du Succès';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: rulesController,
                                onChanged: (value) => success.rules = value,
                                decoration: const InputDecoration(labelText: 'Regles'),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                style: const TextStyle(fontFamily: "Nexa"),
                                controller: conditionController,
                                onChanged: (value) => success.condition = value,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(labelText: 'Condition'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer les conditions du Succès';
                                  }
                                  return null;
                                },
                              ),
                              DropdownButtonFormField<Rarity>(
                                value: success.rarity,
                                onChanged: (Rarity? newValue) {
                                  setState(() {
                                    success.rarity = newValue ?? success.rarity;
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
                              if (!imageChanged && success.image != "")
                                Center(
                                  child: SizedBox(
                                    height: 200,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () {
                                      bool compile = true;
                                      try {
                                        success.evaluate(User(id: 0, username: "username", email: "email", balance: 0, qr: "qr"));
                                      } catch (e) {
                                        compile = false;
                                      }
                                      if (formKey.currentState!.validate()) {
                                        if (compile) {
                                          updateSuccessManage(success);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Le code ne compile pas')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmationDialog(success),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void updateSuccessManage(Success success) async {
    updateSuccess(success).then((res) => {
      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Succès mis à jour avec succès")))
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour du Succès")))
      },
      if (imageChanged) {
        updateSuccessImage(success.id).then((res) =>  {
        if (res) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image mise à jour")))
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour de l'image")))
        }
        }),
        setState(() {
          imageChanged = false;
        }),
      }
    });
  }

  void showDeleteConfirmationDialog(Success success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le succès ${success.libelle} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                deleteSuccessManage(success);
              },
              child: const Text('Oui',style: TextStyle(color: Colors.red),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
              },
              child: const Text('Non'),
            ),
          ],
        );
      },
    );
  }

  void deleteSuccessManage(Success success) {
    deleteSuccess(success).then((res) => {
      if (res) {
        setState(() {
          successList.remove(success);
          filteredSuccessList.remove(success);
          imageChanged = false;
        }),
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Succès supprimé avec succès")))
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème suppression du succès")))
      }
    });
  }
}
