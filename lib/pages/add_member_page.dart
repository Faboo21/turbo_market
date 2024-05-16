import 'package:flutter/material.dart';
import '../api/api_request.dart';
import '../type/payment_method.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  List<PaymentMethod> modesList = [];
  PaymentMethod? selectedPaymentMethod;

  bool btnLoading = false;

  @override
  void initState() {
    getAllPaymentMethod().then((value) => {
      setState(() {
        modesList = value;
      })
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajout d\'un utilisateur'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Merci d\'entrer un pseudo';
                  }
                  return null;
                },
                style: const TextStyle(fontFamily: "Nexa"),
                decoration: const InputDecoration(
                  labelText: 'Pseudo',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white, // Couleur de la bordure inférieure
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(fontFamily: "Nexa"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Merci d\'entrer un email';
                  }
                  if (!value.contains('@')) {
                    return 'Merci d\'entrer un email valide';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white, // Couleur de la bordure inférieure
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: _montantController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Merci d\'entrer une valeur positive';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Merci d\'entrer un entier positif';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  hintText: '10',
                  prefixText: '€',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white, // Couleur de la bordure inférieure
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<PaymentMethod>(
                value: selectedPaymentMethod,
                onChanged: (PaymentMethod? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue;
                  });
                },
                items: modesList.map((PaymentMethod paymentMethod) {
                  return DropdownMenuItem<PaymentMethod>(
                    value: paymentMethod,
                    child: Text(paymentMethod.libelle, style: const TextStyle(fontFamily: "Nexa"),),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Mode de paiement',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez choisir un mode de paiement';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              !btnLoading ? ElevatedButton(
                onPressed: () async {
                  setState(() {
                    btnLoading = true;
                  });
                  if (_formKey.currentState!.validate()) {
                    String username = _usernameController.text;
                    String email = _emailController.text;
                    int montant = int.parse(_montantController.text);

                    if (await insertUser(username, email, montant, selectedPaymentMethod!.payId)){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Utilisateur ajouté"),
                      ));
                      Navigator.pop(context);
                    }else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Probleme d'insertion : un des paramettres n'est pas unique"),
                      ));
                    }
                  }
                  setState(() {
                    btnLoading = false;
                  });
                },
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.inversePrimary)),
              child: const Text("Valider"),
              ) : const Center(child: CircularProgressIndicator(),),
            ],
          ),
        ),
      ),
    );
  }
}