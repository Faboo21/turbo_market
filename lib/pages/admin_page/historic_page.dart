import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/payment_method.dart';
import 'package:turbo_market/type/api_type/prize.dart';
import 'package:turbo_market/type/api_type/transaction.dart';
import 'package:turbo_market/type/api_type/user.dart';
import 'package:turbo_market/api/payment_method_request.dart';
import 'package:turbo_market/api/prize_request.dart';
import 'package:turbo_market/api/transaction_request.dart';
import 'package:turbo_market/api/user_request.dart';


class HistoricPage extends StatefulWidget {
  const HistoricPage({super.key});

  @override
  State<HistoricPage> createState() => _HistoricPageState();
}

class _HistoricPageState extends State<HistoricPage> {
  List<Transaction> filteredTransactions = [];
  List<Transaction> transactions = [];

  DateTime? _startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1);

  List<Prize> prizes = [];
  List<User> users = [];
  List<PaymentMethod> paymentMethods = [];

  List<String> prizesList = [];
  String selectedPrize = "All";

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLists();
  }

  Future<void> loadLists() async {
    List<Transaction> resTransactions = await getAllTransactions();
    List<Prize> resPrizes = await getAllPrizes();
    List<User> resUsers = await getAllUsers();
    List<PaymentMethod> resPaymentMethods = await getAllPaymentMethod();
    if (_startDate == null || _endDate == null) {
      return;
    }

    List<Transaction> filteredTransactions2 = resTransactions.where((partie) {
      DateTime partieDate = DateTime.parse(partie.traTime);
      return (partieDate.isAtSameMomentAs(_startDate!) || partieDate.isAfter(_startDate!)) &&
          (partieDate.isAtSameMomentAs(_endDate!) || partieDate.isBefore(_endDate!));
    }).toList();
    setState(() {
      transactions = filteredTransactions2;
      filteredTransactions = filteredTransactions2;
      prizes = resPrizes;
      prizesList =  ["All", "Prix", "Floppies"] +  List.generate(prizes.length, (index) => prizes[index].name);
      users = resUsers;
      paymentMethods = resPaymentMethods;
    });
    filterTransactions(searchController.text);
  }

  void filterTransactions(String query) {
    List<Transaction> resFilteredTransactions = transactions.where((transaction) {
      User user = users.where((element) => element.id == transaction.usrId).first;
      Prize? prize = prizes.where((element) => element.name == selectedPrize).firstOrNull;
      if (selectedPrize == "All") {
        return (transaction.traTime.toLowerCase().contains(query.toLowerCase()) || user.username.toLowerCase().contains(query.toLowerCase()) || user.email.toLowerCase().contains(query.toLowerCase()));
      }
      else if (selectedPrize == "Prix") {
        return (transaction.traTime.toLowerCase().contains(query.toLowerCase()) || user.username.toLowerCase().contains(query.toLowerCase()) || user.email.toLowerCase().contains(query.toLowerCase())) && transaction.priId != 0;
      }
      else if (selectedPrize == "Floppies") {
        return (transaction.traTime.toLowerCase().contains(query.toLowerCase()) || user.username.toLowerCase().contains(query.toLowerCase()) || user.email.toLowerCase().contains(query.toLowerCase())) && transaction.priId == 0;
      }
      else {
        return (transaction.traTime.toLowerCase().contains(query.toLowerCase()) || user.username.toLowerCase().contains(query.toLowerCase()) || user.email.toLowerCase().contains(query.toLowerCase())) && transaction.priId == prize?.id;
      }
    }).toList();
    setState(() {
      filteredTransactions = resFilteredTransactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Center(child: Text("Total : ${filteredTransactions.length}"),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterTransactions,
              decoration: const InputDecoration(
                labelText: 'Rechercher par date, nom ou email du joueur',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _showDatePicker(context);
                  },
                  icon: const Icon(Icons.calendar_month),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedPrize,
                    onChanged: (newValue) {
                      setState(() {
                        selectedPrize = newValue!;
                      });
                      filterTransactions(searchController.text);
                    },
                    items: prizesList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                Transaction transaction = filteredTransactions[index];
                Prize? prize = prizes.where((element) => element.id == transaction.priId).firstOrNull;
                User user = users.where((element) => element.id == transaction.usrId).first;
                PaymentMethod? paymentMethod = paymentMethods.where((element) => element.payId == transaction.payId).firstOrNull;
                return ExpansionTile(
                  leading: transaction.priId == 0 ? const Icon(Icons.monetization_on, size: 30, color: Colors.white,) :
                  SizedBox(
                    width: 30,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          prize!.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: transaction.priId == 0 ? Text('${transaction.traAmount*AppConfig.rate}ƒ') : Text('${transaction.traAmount}x ${prize?.name}'),
                  trailing: Text(user.username),
                  children: [
                    ListTile(
                      title: Text('Date: ${transaction.traTime}'),
                      trailing: paymentMethod != null ? Text(paymentMethod.libelle) : null,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      )
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
                    loadLists();
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