import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:turbo_market/api/rarity_request.dart';
import 'package:turbo_market/type/api_type/rarity.dart';
import 'package:turbo_market/dialogs/admin/create_rarity_modale.dart';

class RarityManagementPage extends StatefulWidget {
  const RarityManagementPage({super.key});

  @override
  State<RarityManagementPage> createState() => _RarityManagementPageState();
}

class _RarityManagementPageState extends State<RarityManagementPage> {
  List<Rarity> raritiesList = [];
  List<Rarity> filteredRaritiesList = [];

  TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    loadPaymentMethods();
    super.initState();
  }

  Future<void> loadPaymentMethods() async {
    List<Rarity> resList = await getAllRarities();
    setState(() {
      raritiesList = resList;
      filteredRaritiesList = raritiesList;
    });
  }

  void filterRarities(String query) {
    List<Rarity> filteredRarities = raritiesList.where((rarity) => rarity.libelle.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredRaritiesList = filteredRarities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raretés'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return const CreateRarityPage();
            },
          ).then((value) async {
            await loadPaymentMethods();
            filterRarities(searchController.text);
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
              onChanged: filterRarities,
              decoration: const InputDecoration(
                labelText: 'Rechercher par libellé',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRaritiesList.length,
              itemBuilder: (context, index) {
                Rarity rarity = filteredRaritiesList[index];
                TextEditingController libelleController = TextEditingController(text: rarity.libelle);
                TextEditingController valueController = TextEditingController(text: rarity.value.toString());

                final formKey = GlobalKey<FormState>();

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(rarity.libelle, style: TextStyle(color: rarity.displayColor),),
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
                                onChanged: (value) => rarity.libelle = value,
                                decoration: const InputDecoration(labelText: 'Libellé'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le libellé';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: valueController,
                                onChanged: (value) => rarity.value = int.tryParse(value) ?? 0,
                                decoration: const InputDecoration(labelText: 'Valeur'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer la valeur';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Merci d\'entrer un entier';
                                  }
                                  if (int.parse(value) <= 0) {
                                    return 'Merci d\'entrer un entier supérieur à 0';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              ColorPicker(
                                  pickerColor: rarity.displayColor,
                                  onColorChanged: (value) {
                                    rarity.color = "0x${value.toHexString()}";
                                  }
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        updateManageRarity(rarity);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmationDialog(rarity),
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

  void updateManageRarity(Rarity paymentMethod) async {
    updateRarity(paymentMethod).then((res) {
      if (res) {
        setState(() {
          //for refresh color
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rareté mise à jour avec succès")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour de la rareté")));
      }
    });
  }

  void showDeleteConfirmationDialog(Rarity paymentMethod) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer la rareté ${paymentMethod.libelle} ? Tout les succès avec cette rareté serons supprimés'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                deleteManageRarity(paymentMethod);
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

  void deleteManageRarity(Rarity paymentMethod) async {
    deleteRarity(paymentMethod).then((res) {
      if (res) {
        setState(() {
          raritiesList.remove(paymentMethod);
          filteredRaritiesList.remove(paymentMethod);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rareté supprimé avec succès")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème suppression de la Rareté")));
      }
    });
  }
}
