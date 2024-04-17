import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/user.dart';

class ManageBalance extends StatefulWidget {
  const ManageBalance({super.key, required this.selectedUser});

  final User selectedUser;

  @override
  State<ManageBalance> createState() => _ManageBalanceState();
}

class _ManageBalanceState extends State<ManageBalance> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du solde'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Montant',
              hintText: '10',
              suffixText: '€',
            ),
          ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (_amountController.text.isNotEmpty) {
                  double amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (amount != 0.0 && widget.selectedUser.balance + amount >= 0) {
                    Navigator.pop(context, await updateUserBalance(widget.selectedUser, widget.selectedUser.balance + amount));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir un montant correct')),);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir un montant')),);
                }
              },
              child: const Text('Modifier le solde'),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Solde actuel : ${widget.selectedUser.balance * AppConfig.taux} ƒ',
              style: const TextStyle(fontSize: 18.0),
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
