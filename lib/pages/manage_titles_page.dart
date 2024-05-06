import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/rarity.dart';
import 'package:turbo_market/type/title.dart';

import '../dialogs/create_title_modale.dart';

class TitleManagementPage extends StatefulWidget {
  const TitleManagementPage({super.key});

  @override
  State<TitleManagementPage> createState() => _TitleManagementPageState();
}

class _TitleManagementPageState extends State<TitleManagementPage> {
  List<UserTitle> titleList = [];
  List<UserTitle> filteredTitleList = [];

  TextEditingController searchController = TextEditingController();
  bool imageChanged = false;

  @override
  void initState() {
    loadTitles();
    super.initState();
  }

  Future<void> loadTitles() async {
    List<UserTitle> resList = await getAllTitles();
    setState(() {
      titleList = resList;
      filteredTitleList = titleList;
    });
  }

  void filterTitles(String query) {
    List<UserTitle> filteredTitles = titleList.where((title) => title.libelle.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredTitleList = filteredTitles;
    });
  }

  Future<void> _pickImageFromGallery() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((pickedImage) => {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload en cours"))),
      if (pickedImage != null) {
        uploadTitleImageToAPI(pickedImage, "temp").then((value) => {
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
        title: const Text('Titre'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return const CreateTitlePage();
            },
          ).then((value) async {
            await loadTitles();
            filterTitles(searchController.text);
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
              onChanged: filterTitles,
              decoration: const InputDecoration(
                labelText: 'Rechercher par nom du titre',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTitleList.length,
              itemBuilder: (context, index) {
                UserTitle title = filteredTitleList[index];
                TextEditingController libelleController = TextEditingController(text: title.libelle);
                TextEditingController rulesController = TextEditingController(text: title.rules);
                TextEditingController conditionController = TextEditingController(text: title.condition);

                final formKey = GlobalKey<FormState>();

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
                            "${title.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    title: Text(title.libelle, style: TextStyle(color: title.rarity.color),),
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
                                onChanged: (value) => title.libelle = value,
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
                                onChanged: (value) => title.rules = value,
                                decoration: const InputDecoration(labelText: 'Description'),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: conditionController,
                                onChanged: (value) => title.condition = value,
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
                                value: title.rarity,
                                onChanged: (Rarity? newValue) {
                                  setState(() {
                                    title.rarity = newValue ?? Rarity.common;
                                  });
                                },
                                items: Rarity.values.map((Rarity rarity) {
                                  return DropdownMenuItem<Rarity>(
                                    value: rarity,
                                    child: Text(rarity.displayString, style: const TextStyle(fontFamily: "Nexa"),),
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
                              if (!imageChanged && title.image != "")
                                Center(
                                  child: SizedBox(
                                    height: 200,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          "${title.image}?random=${DateTime.now().millisecondsSinceEpoch}",
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
                                    onPressed: () => {
                                      if (formKey.currentState!.validate())
                                        updateTitleManage(title)
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmationDialog(title),
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

  void updateTitleManage(UserTitle title) async {
    updateTitle(title).then((res) => {
      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Titre mis à jour avec succès")))
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour du titre")))
      },
      if (imageChanged) {
        updateTitleImage(title.id).then((res) =>  {
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

  void showDeleteConfirmationDialog(UserTitle title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le titre ${title.libelle} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                deleteTitleManage(title);
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

  void deleteTitleManage(UserTitle title) {
    deleteTitle(title).then((res) => {
      if (res) {
        setState(() {
          titleList.remove(title);
          filteredTitleList.remove(title);
          imageChanged = false;
        }),
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Titre supprimé avec succès")))
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème suppression du titre")))
      }
    });
  }
}
