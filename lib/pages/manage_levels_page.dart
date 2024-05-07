import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/level.dart';
import '../dialogs/create_level_modale.dart';
import '../type/game.dart';

class LevelManagementPage extends StatefulWidget {
  const LevelManagementPage({super.key, required this.game});

  final Game game;

  @override
  State<LevelManagementPage> createState() => _LevelManagementPageState();
}

class _LevelManagementPageState extends State<LevelManagementPage> {
  List<Level> levelList = [];

  @override
  void initState() {
    loadLevels();
    super.initState();
  }

  Future<void> loadLevels() async {
    List<Level> resList = await getAllLevels(widget.game.id);
    setState(() {
      levelList = resList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Niveau : ${widget.game.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return CreateLevelPage(game: widget.game,);
            },
          ).then((value) async {
            await loadLevels();
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: levelList.length,
              itemBuilder: (context, index) {
                Level level = levelList[index];
                TextEditingController stepController = TextEditingController(text: level.step.toString());
                TextEditingController libelleController = TextEditingController(text: level.libelle);
                TextEditingController priceController = TextEditingController(text: level.cashPrize.toString());
                TextEditingController scoreController = TextEditingController(text: level.score.toString());

                final formKey = GlobalKey<FormState>();

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text("${level.step.toString()} : ${level.libelle == "" ? "${level.cashPrize * AppConfig.rate} ƒ" : level.libelle}"),
                    children: [
                      Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: stepController,
                                onChanged: (value) => level.step = int.tryParse(value) ?? level.step,
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
                                onChanged: (value) => level.libelle = value,
                                decoration: const InputDecoration(labelText: 'Libelle (null si recompense en floppies)'),
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: priceController,
                                onChanged: (value) => level.cashPrize = double.tryParse(value) ?? level.cashPrize,
                                decoration: const InputDecoration(labelText: 'Recompense', suffix: Text("€")),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer la recompense';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'La recompense doit être un nombre';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: scoreController,
                                onChanged: (value) => level.score = int.tryParse(value) ?? level.score,
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
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        updateLevelManage(level);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmationDialog(level),
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

  void updateLevelManage(Level level) async {
    updateLevel(level).then((res) => {
      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jeu mis à jour avec succès")))
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour du jeu")))
      }
    });
  }

  void showDeleteConfirmationDialog(Level level) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le niveau ${level.step} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                deleteLevelManage(level);
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

  void deleteLevelManage(Level level) async {
    deleteLevel(level).then((res) => {
      if (res) {
        setState(() {
          levelList.remove(level);
        }),
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jeu supprimé avec succès")))
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème suppression du jeu")))
      }
    });
  }
}
