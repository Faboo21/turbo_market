import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import '../type/prize.dart';

class CreatePrizePage extends StatefulWidget {
  const CreatePrizePage({super.key});

  @override
  State<CreatePrizePage> createState() => _CreatePrizePageState();
}

class _CreatePrizePageState extends State<CreatePrizePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un prix'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom du prix'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un nom pour le prix';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer une description pour le prix';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un prix pour le prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Le prix doit être un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le stock pour le prix';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Le stock doit être un entier';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      insertPrize(
                        Prize(
                          id: 0,
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          stock: int.parse(stockController.text),
                          createdAt: '',
                          image: '',
                        ),
                      ).then((success) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Prix créé avec succès')),
                          );
                          Navigator.pop(context); // Close the modal after successful creation
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Erreur lors de la création du prix')),
                          );
                        }
                      });
                    }
                  },
                  child: const Text('Créer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
