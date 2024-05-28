import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turbo_market/dialogs/admin/create_success_modale.dart';
import 'package:turbo_market/type/api_type/rarity.dart';
import 'package:turbo_market/type/api_type/success.dart';
import 'package:turbo_market/api/rarity_request.dart';
import 'package:turbo_market/api/success_request.dart';

class SuccessManagementPage extends StatefulWidget {
  const SuccessManagementPage({super.key});

  @override
  State<SuccessManagementPage> createState() => _SuccessManagementPageState();
}

class _SuccessManagementPageState extends State<SuccessManagementPage> with TickerProviderStateMixin {
  List<Success> successList = [];
  List<Success> filteredSuccessList = [];

  TextEditingController searchController = TextEditingController();
  bool imageChanged = false;
  List<Rarity> rarities = [];

  late GifController _controller;

  @override
  void initState() {
    setState(() {
      _controller = GifController(vsync: this);
    });
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

                final formKey = GlobalKey<FormState>();
                success.rarity = rarities.firstWhere((element) => element.id == success.rarity.id, orElse: () => rarities.first);

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    leading: success.rarity.id != rarities.last.id ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius
                                .circular(50),
                            child: Container(
                              width: 30,
                              height: 30,
                              color: success.rarity.displayColor,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                child:
                                Image.network(
                                  "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ),
                        ]
                    ) :
                    Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius
                                .circular(50),
                            child: Container(
                              width: 30,
                              height: 30,
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
                            width: 30,
                            height: 30,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                child:
                                Image.network(
                                  "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child:
                              Gif(
                                image: const AssetImage(
                                    "images/giphy.gif"),
                                controller: _controller,
                                // if duration and fps is null, original gif fps will be used.
                                //fps: 30,
                                //duration: const Duration(seconds: 3),
                                autostart: Autostart.loop,
                                placeholder: (context) =>
                                const Text('Loading...'),
                                onFetchCompleted: () {
                                  _controller.reset();
                                  _controller.forward();
                                },
                              ),
                            ),
                          )
                        ]
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
                              Row(
                                children: [
                                  const Text("Succès perdable : "),
                                  Checkbox(
                                    onChanged: (value) {setState(() {
                                      success.losable = value ?? true;
                                    });},
                                    value: success.losable,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              DropdownButtonFormField<int>(
                                value: success.type,
                                onChanged: (newValue) {
                                  setState(() {
                                    success.type = newValue ?? 0;
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
                              if (!imageChanged && success.image != "")
                                success.rarity.id != rarities.last.id ? Center(
                                  child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius
                                              .circular(500),
                                          child: Container(
                                            width: 300,
                                            height: 300,
                                            color: success.rarity.displayColor,
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
                                                "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
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
                                                "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                                                width: 200,
                                                height: 200,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                  ),
                                ),
                              if (imageChanged)
                                success.rarity.id != rarities.last.id ? Center(
                                  child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius
                                              .circular(500),
                                          child: Container(
                                            width: 300,
                                            height: 300,
                                            color: success.rarity.displayColor,
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
                                        dynamic res = await Navigator.pushNamed(context, "/ide", arguments: success);
                                        if (res is String) {
                                          success.condition = res;
                                        }
                                      },
                                      child: const Text("Ouvrir l'IDE"),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        updateSuccessManage(success);
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
      setState(() {}),
      if (imageChanged) {
        updateSuccessImage(success.id).then((res) =>  {
        if (res) {
          setState(() {
            success.image = "https://obsolete-events.com/turbo-market/app/images/titles/title${success.id}?random=${DateTime.now().millisecondsSinceEpoch}";
          }),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
