import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/dialogs/create_prize_modale.dart';
import 'package:turbo_market/type/prize.dart';

class PrizeManagementPage extends StatefulWidget {
  const PrizeManagementPage({super.key});

  @override
  State<PrizeManagementPage> createState() => _PrizeManagementPageState();
}

class _PrizeManagementPageState extends State<PrizeManagementPage> {
  List<Prize> prizeList = [];
  List<Prize> filteredPrizeList = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    loadPrizes();
    super.initState();
  }

  void loadPrizes() async {
    List<Prize> resList = await getAllPrizes();
    setState(() {
      prizeList = resList;
      filteredPrizeList = prizeList;
    });
  }

  void filterPrizes(String query) {
    List<Prize> filteredPrizes = prizeList.where((prize) => prize.name.toLowerCase().contains(query.toLowerCase()) || prize.description.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredPrizeList = filteredPrizes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des prix'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return const CreatePrizePage();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterPrizes,
              decoration: const InputDecoration(
                labelText: 'Rechercher par nom / description du prix',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPrizeList.length,
              itemBuilder: (context, index) {
                Prize prize = filteredPrizeList[index];
                TextEditingController nameController = TextEditingController(text: prize.name);
                TextEditingController descriptionController = TextEditingController(text: prize.description);
                TextEditingController priceController = TextEditingController(text: prize.price.toString());
                TextEditingController stockController = TextEditingController(text: prize.stock.toString());

                final formKey = GlobalKey<FormState>();

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(prize.name),
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
                                onChanged: (value) => prize.name = value,
                                decoration: const InputDecoration(labelText: 'Nom du prix'),
                                validator:  (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le nom du prix';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: descriptionController,
                                onChanged: (value) => prize.description = value,
                                decoration: const InputDecoration(labelText: 'Description'),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: priceController,
                                onChanged: (value) => prize.price = double.tryParse(value) ?? 0,
                                decoration: const InputDecoration(labelText: 'Prix'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le prix du prix';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Le prix doit être un nombre';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: stockController,
                                onChanged: (value) => prize.stock = int.tryParse(value) ?? 0,
                                decoration: const InputDecoration(labelText: 'Stock'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le stock du prix';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Le stock doit être un entier';
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
                                    onPressed: () => {
                                      if (formKey.currentState!.validate())
                                        updatePrizeManage(prize)
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmationDialog(prize),
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

  void updatePrizeManage(Prize prize) async {
    bool res = await updatePrize(prize);
    if (res) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prix mis à jour avec succès")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour du prix")));
    }
  }

  void showDeleteConfirmationDialog(Prize prize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le prix ${prize.name} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                deletePrizeManage(prize);
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

  void deletePrizeManage(Prize prize) async {
    bool res = await deletePrize(prize);
    if (res) {
      setState(() {
        prizeList.remove(prize);
        filteredPrizeList.remove(prize);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prix supprimé avec succès")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème suppression du prix")));
    }
  }
}
