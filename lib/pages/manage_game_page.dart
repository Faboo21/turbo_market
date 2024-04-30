import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/game.dart';
import '../dialogs/create_game_modale.dart';

class GameManagementPage extends StatefulWidget {
  const GameManagementPage({super.key});

  @override
  State<GameManagementPage> createState() => _GameManagementPageState();
}

class _GameManagementPageState extends State<GameManagementPage> {
  List<Game> gameList = [];
  List<Game> filteredGameList = [];

  TextEditingController searchController = TextEditingController();
  bool imageChanged = false;

  @override
  void initState() {
    loadGames();
    super.initState();
  }

  Future<void> loadGames() async {
    List<Game> resList = await getAllGames();
    setState(() {
      gameList = resList;
      filteredGameList = gameList;
    });
  }

  void filterGames(String query) {
    List<Game> filteredGames = gameList.where((game) => game.name.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredGameList = filteredGames;
    });
  }

  Future<void> _pickImageFromGallery() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((pickedImage) => {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload en cours"))),
      if (pickedImage != null) {
        uploadGameImageToAPI(pickedImage, "temp").then((value) => {
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
        title: const Text('Jeux'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return const CreateGamePage();
            },
          ).then((value) {
            loadGames().then((value) {
              filterGames(searchController.text);
            });
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
              onChanged: filterGames,
              decoration: const InputDecoration(
                labelText: 'Rechercher par nom du jeu',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredGameList.length,
              itemBuilder: (context, index) {
                Game game = filteredGameList[index];
                TextEditingController nameController = TextEditingController(text: game.name);
                TextEditingController rulesController = TextEditingController(text: game.rules);
                TextEditingController priceController = TextEditingController(text: game.price.toString());
                TextEditingController nbPlayersMinController = TextEditingController(text: game.nbPlayersMin.toString());
                TextEditingController nbPlayersMaxController = TextEditingController(text: game.nbPlayersMax.toString());

                final formKey = GlobalKey<FormState>();

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(game.name),
                    children: [
                      Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: nameController,
                                onChanged: (value) => game.name = value,
                                decoration: const InputDecoration(labelText: 'Nom du jeu'),
                                validator:  (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le nom du jeu';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: rulesController,
                                onChanged: (value) => game.rules = value,
                                decoration: const InputDecoration(labelText: 'Règles'),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: priceController,
                                onChanged: (value) => game.price = double.tryParse(value) ?? 0,
                                decoration: const InputDecoration(labelText: 'Prix'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le prix du jeu';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Le prix doit être un nombre';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: nbPlayersMinController,
                                onChanged: (value) => game.nbPlayersMin = int.tryParse(value) ?? 0,
                                decoration: const InputDecoration(labelText: 'Nombre de joueurs minimum'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le nombre de joueurs minimum';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Le nombre de joueurs minimum doit être un entier';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: nbPlayersMaxController,
                                onChanged: (value) => game.nbPlayersMax = int.tryParse(value) ?? 0,
                                decoration: const InputDecoration(labelText: 'Nombre de joueurs maximum'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le nombre de joueurs maximum';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Le nombre de joueurs maximum doit être un entier';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              if (!imageChanged && game.image != "")
                                Center(
                                  child: SizedBox(
                                    height: 200,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        "${game.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }
                                        },
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
                                          "https://obsolete-events.com/turbo-market/app/images/games/temp?random=${DateTime.now().millisecondsSinceEpoch}",
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return const Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            }
                                          },
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                              ),
                              const SizedBox(height: 15,),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _pickImageFromGallery,
                                  child: const Text('Choisir depuis la galerie'),
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
                                        updateGameManage(game);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmationDialog(game),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.settings),
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/manage_levels", arguments: game);
                                    },
                                  ),
                                ],
                              ),
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

  void updateGameManage(Game game) async {
    updateGame(game).then((res) => {
      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jeu mis à jour avec succès")))
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour du jeu")))
      }
    });
    if (imageChanged) {
      updateGameImage(game.id).then((res) =>  {
        if (res) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image mise à jour")))
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour de l'image")))
        }
      });
      setState(() {
        imageChanged = false;
      });
    }
  }

  void showDeleteConfirmationDialog(Game game) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le jeu ${game.name} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                deleteGameManage(game);
              },
              child: const Text('Oui', style: TextStyle(color: Colors.red)),
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

  void deleteGameManage(Game game) async {
    deleteGame(game).then((res) => {
      if (res) {
        setState(() {
          gameList.remove(game);
          filteredGameList.remove(game);
          imageChanged = false;
        }),
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jeu supprimé avec succès")))
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème suppression du jeu")))
      }
    });
  }
}
