import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turbo_market/dialogs/admin/create_payment_modale.dart';
import 'package:turbo_market/type/api_type/payment_method.dart';
import 'package:turbo_market/api/payment_method_request.dart';

class PaymentMethodManagementPage extends StatefulWidget {
  const PaymentMethodManagementPage({super.key});

  @override
  State<PaymentMethodManagementPage> createState() => _PaymentMethodManagementPageState();
}

class _PaymentMethodManagementPageState extends State<PaymentMethodManagementPage> {
  List<PaymentMethod> paymentMethodList = [];
  List<PaymentMethod> filteredPaymentMethodList = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    loadPaymentMethods();
    super.initState();
  }

  Future<void> loadPaymentMethods() async {
    List<PaymentMethod> resList = await getAllPaymentMethod();
    int max = 0;
    for (var element in resList) {if (element.payId > max) max = element.payId;}
    setState(() {
      paymentMethodList = resList;
      filteredPaymentMethodList = paymentMethodList;
    });
  }

  void filterPaymentMethods(String query) {
    List<PaymentMethod> filteredMethods = paymentMethodList.where((method) => method.libelle.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredPaymentMethodList = filteredMethods;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modes de paiement'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return const CreatePaymentMethodPage();
            },
          ).then((value) async {
            await loadPaymentMethods();
            filterPaymentMethods(searchController.text);
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
              onChanged: filterPaymentMethods,
              decoration: const InputDecoration(
                labelText: 'Rechercher par libellé',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPaymentMethodList.length,
              itemBuilder: (context, index) {
                PaymentMethod paymentMethod = filteredPaymentMethodList[index];
                TextEditingController libelleController = TextEditingController(text: paymentMethod.libelle);

                final formKey = GlobalKey<FormState>();

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(paymentMethod.libelle),
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
                                onChanged: (value) => paymentMethod.libelle = value,
                                decoration: const InputDecoration(labelText: 'Libellé'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le libellé';
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
                                        updatePayment(paymentMethod);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmationDialog(paymentMethod),
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

  void updatePayment(PaymentMethod paymentMethod) async {
    bool res = await updatePaymentMethod(paymentMethod);
    if (res) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mode de paiement mis à jour avec succès")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour du mode de paiement")));
    }
    setState(() {});
  }

  void showDeleteConfirmationDialog(PaymentMethod paymentMethod) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le mode de paiement "${paymentMethod.libelle}" ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                deletePayment(paymentMethod);
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

  void deletePayment(PaymentMethod paymentMethod) async {
    bool res = await deletePaymentMethod(paymentMethod);
    if (res) {
      setState(() {
        paymentMethodList.remove(paymentMethod);
        filteredPaymentMethodList.remove(paymentMethod);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mode de paiement supprimé avec succès")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème suppression du mode de paiement")));
    }
  }
}
