import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:turbo_market/api/payment_method_request.dart';
import 'package:turbo_market/api/prize_request.dart';
import 'package:turbo_market/api/transaction_request.dart';
import 'package:turbo_market/type/api_type/payment_method.dart';
import 'package:turbo_market/type/api_type/transaction.dart';

import '../../api/user_request.dart';
import '../../type/api_type/prize.dart';
import '../../type/api_type/user.dart';

class AccountacyPage extends StatefulWidget {
  const AccountacyPage({super.key});

  @override
  State<AccountacyPage> createState() => _AccountacyPageState();
}

class _AccountacyPageState extends State<AccountacyPage> {
  List<double> caPerMethods = [0];
  double prizesCost = 0;
  double benefits = 0;
  double totalCA = 0;
  double total = 0;

  List<PaymentMethod?> paymentMethod = [null];

  DateTime? _startDate = DateTime(2024);
  DateTime? _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

  @override
  void initState() {
    calculate();
    loadTotal();
    super.initState();
  }

  Future<void> loadTotal() async {
    double resTotal = 0;
    List<User> resList = await getAllUsers();

    for (var element in resList) {
      resTotal += element.balance;
    }
    setState(() {
      total = resTotal;
    });
  }

  Future<void> calculate() async {
    List<Transaction> transactions = await getAllTransactions();
    List<Prize> prizes = await getAllPrizes();
    List<PaymentMethod> methods = await getAllPaymentMethod();
    int maxId = methods.map((e) => e.payId).toList().max;

    if (_startDate == null || _endDate == null) {
      return;
    }

    List<Transaction> filteredTransactions = transactions.where((partie) {
      DateTime partieDate = DateTime.parse(partie.traTime);
      return (partieDate.isAtSameMomentAs(_startDate!) || partieDate.isAfter(_startDate!)) &&
          (partieDate.isAtSameMomentAs(_endDate!) || partieDate.isBefore(_endDate!));
    }).toList();

    List<double> ca = List.filled(maxId + 1, 0);
    double cost = 0;
    for (var transaction in filteredTransactions) {
      if (transaction.priId == 0) {
        ca[transaction.payId] += transaction.traAmount;
      } else {
        cost += prizes.where((e) => e.id == transaction.priId).first.cost;
      }
    }

    loadTotal();

    setState(() {
      paymentMethod = methods;
      caPerMethods = ca;
      prizesCost = cost;
      benefits = ca.sum - prizesCost;
      totalCA = ca.sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilan comptable'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            InkWell(
              onTap: () {
                _showDatePicker(context);
              },
              child: const Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(Icons.calendar_month),
                  title: Text('Sélectionnez une date'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('')),
                      ...paymentMethod.map((e) => DataColumn(label: Text(e?.libelle ?? ""))),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Center(child: Text('CA'))),
                        ...paymentMethod.map((e) => DataCell(Center(child: Text(caPerMethods[e?.payId ?? 0].toStringAsFixed(2))))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Center(child: Text('CA total'))),
                        DataCell(Center(child: Text(totalCA.toStringAsFixed(2))), placeholder: true),
                        for (var i = 1; i < paymentMethod.length; i++) DataCell.empty,
                      ]),
                      DataRow(cells: [
                        const DataCell(Center(child: Text('Couts'))),
                        DataCell(Center(child: Text(prizesCost.toStringAsFixed(2))), placeholder: true),
                        for (var i = 1; i < paymentMethod.length; i++) DataCell.empty,
                      ]),
                      DataRow(cells: [
                        const DataCell(Center(child: Text('Bénéfices'))),
                        DataCell(Center(child: Text(benefits.toStringAsFixed(2))), placeholder: true),
                        for (var i = 1; i < paymentMethod.length; i++) DataCell.empty,
                      ]),
                      DataRow(cells: [
                        const DataCell(Center(child: SizedBox(width: 120,child: Text('Argent Actif'),))),
                        DataCell(Center(child: Text(total.toString())), placeholder: true),
                        for (var i = 1; i < paymentMethod.length; i++) DataCell.empty,
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date Range'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  if (args.value is PickerDateRange) {
                    setState(() {
                      _startDate = args.value.startDate;
                      _endDate = args.value.endDate;
                    });
                    calculate();
                  }
                });
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}