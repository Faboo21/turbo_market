import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/user.dart';

import '../type/payment_method.dart';

class ManageBalance extends StatefulWidget {
  const ManageBalance({super.key, required this.selectedUser});

  final User selectedUser;

  @override
  State<ManageBalance> createState() => _ManageBalanceState();
}

class _ManageBalanceState extends State<ManageBalance> {
  final TextEditingController _amountController = TextEditingController();


  List<PaymentMethod> modesList = [];
  PaymentMethod? selectedPaymentMethod;

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Solde actuel : ${widget.selectedUser.balance * AppConfig.taux} ƒ',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant',
                hintText: '10',
                suffixText: '€',
                border: OutlineInputBorder(),
              ),
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
            ElevatedButton(
              onPressed: () async {
                if (_amountController.text.isNotEmpty) {
                  double amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (amount != 0.0 && widget.selectedUser.balance + amount >= 0) {
                    bool res = true;
                    res = await addTransaction(widget.selectedUser.id, 0, amount, selectedPaymentMethod!.payId);
                    res = await updateUserBalance(widget.selectedUser, widget.selectedUser.balance + amount) && res;
                    Navigator.pop(context, res);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir un montant correct')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir un montant')));
                }
              },
              child: const Text('Modifier le solde'),
            ),
          ],
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
