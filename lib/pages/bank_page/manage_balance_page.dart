import 'package:flutter/material.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/payment_method.dart';
import 'package:turbo_market/type/api_type/user.dart';
import 'package:turbo_market/api/payment_method_request.dart';
import 'package:turbo_market/api/transaction_request.dart';

class ManageBalance extends StatefulWidget {
  const ManageBalance({super.key, required this.selectedUser});

  final User selectedUser;

  @override
  State<ManageBalance> createState() => _ManageBalanceState();
}

class _ManageBalanceState extends State<ManageBalance> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        title: const Text('Gestion du solde'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Solde actuel : ${widget.selectedUser.balance * AppConfig.rate}ƒ',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  hintText: '10',
                  prefixText: '€',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  value = value?.replaceAll(",", ".");
                  if (value!.isEmpty) {
                    return 'Merci d\'entrer une valeur';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Merci d\'entrer un nombre';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Merci d\'entrer un nombre positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
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
                    double amount = double.tryParse(_amountController.text.replaceAll(",", ".")) ?? 0;
                    bool res = true;
                    res = await addTransaction(widget.selectedUser.id, 0, amount, selectedPaymentMethod!.payId);
                    widget.selectedUser.balance += amount;
                    Navigator.pop(context, res);
                  }
                  setState(() {
                    btnLoading = false;
                  });
                },
                child: const Text('Modifier le solde'),
              ) : const Center(child: CircularProgressIndicator(),),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
