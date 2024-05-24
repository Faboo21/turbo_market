import 'package:flutter/material.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/api/game_request.dart';
import 'package:turbo_market/type/api_type/game.dart';
import 'package:turbo_market/type/api_type/level.dart';
import 'package:turbo_market/type/api_type/prize.dart';
import 'package:turbo_market/type/api_type/stats_play.dart';
import 'package:turbo_market/type/api_type/success.dart';
import 'package:turbo_market/type/api_type/transaction.dart';
import 'package:turbo_market/type/api_type/user.dart';
import 'package:turbo_market/api/level_request.dart';
import 'package:turbo_market/api/prize_request.dart';
import 'package:turbo_market/api/stats_play_request.dart';
import 'package:turbo_market/api/success_request.dart';
import 'package:turbo_market/api/transaction_request.dart';
import 'package:turbo_market/api/user_request.dart';

import '../../api/users_success_request.dart';

class PrizesPage extends StatefulWidget {
  const PrizesPage({super.key, required this.selectedUser, this.showSuccess = true});
  final User selectedUser;
  final bool showSuccess;

  @override
  State<PrizesPage> createState() => _PrizesPageState();
}

class _PrizesPageState extends State<PrizesPage> {
  List<Prize> prizesList = [];
  List<int> quantityList = [];
  double totalPrice = 0;

  bool btnLoading = false;

  int random = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    loadPrizes();
  }

  List<Success> oldSuccess = [];
  List<Success> actualSuccess = [];

  Future<void> loadOldSuccess() async {
    oldSuccess = await getAllSuccessByUserId(widget.selectedUser.id);
  }

  Future<void> loadNewSuccess() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("Chargement des succès"),
        );
      },
    );
    List<User> users = await getAllUsers();
    List<StatsPlay> plays = await getAllStatsPlays();
    List<Game> games = await getAllGames();
    List<Transaction> transactionsList = await getAllTransactions();
    List<Level> levelList = await getAllLevelsActive();
    List<Prize> prizesList = await getAllPrizes();
    List<Success> successList = await getAllSuccess();
    List<Success> validSuccess = [];
    List<Success> oldSuccessUser = oldSuccess.where((element) => element.losable == false).toList();
    for (var success in successList) {
      if (success.losable || !oldSuccess.contains(success)) {
        if (success.type == 2 && success.evaluateTransaction(widget.selectedUser, users, prizesList, transactionsList)) {
          validSuccess.add(success);
        }
        if (success.type == 0 && success.evaluate(widget.selectedUser, plays, users, games, levelList, prizesList, transactionsList)) {
          validSuccess.add(success);
        }
      }
      actualSuccess = oldSuccessUser + validSuccess;
    }
    String newSuccess = "";
    String loseSuccess = "";
    for (var success in successList){
      if (actualSuccess.any((element) => element.id == success.id) && !oldSuccess.any((element) => element.id == success.id)){
        insertUsersSuccess(widget.selectedUser.id, success.id);
        newSuccess += "${success.libelle}, ";
      }
      if (oldSuccess.any((element) => element.id == success.id) && !actualSuccess.any((element) => element.id == success.id)){
        deleteUsersSuccess(widget.selectedUser.id, success.id);
        loseSuccess += "${success.libelle}, ";
      }
    }
    if (newSuccess != ""){
      newSuccess = newSuccess.substring(0,newSuccess.length-2);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nouveau succès : $newSuccess")));
    }
    if (loseSuccess != ""){
      loseSuccess = loseSuccess.substring(0,loseSuccess.length-2);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Succès perdu : $loseSuccess")));
    }
    Navigator.pop(context);
  }

  Future<void> loadPrizes() async {
    List<Prize> resList = await getAllPrizes();
    setState(() {
      quantityList = List<int>.filled(resList.length, 0);
      prizesList = resList;
    });
    if (widget.showSuccess) {
      await loadOldSuccess();
    }
  }

  void updateTotalPrice() {
    double sum = 0;
    for (int i = 0; i < prizesList.length; i++) {
      sum += prizesList[i].price * quantityList[i];
    }
    setState(() {
      totalPrice = sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperation des lots'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView.builder(
        itemCount: prizesList.length,
        itemBuilder: (context, index) {
          Prize prize = prizesList[index];
          return ListTile(
            enabled: quantityList[index] < prize.stock,
            onTap: quantityList[index] < prize.stock ? () {
              quantityList[index]++;
              updateTotalPrice();
            } : null,
            leading:
            AspectRatio(
              aspectRatio: 1, // Aspect ratio 1:1 for square image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  "${prize.image}?random=$random",
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          // Vous pouvez personnaliser l'indicateur de chargement selon vos besoins
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            title: Text(
              prize.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  'Prix : ${prize.price*AppConfig.rate}ƒ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Stock : ${prize.stock}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            trailing: quantityList[index] > 0 ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: quantityList[index] > 0 ? () {
                    setState(() {
                      quantityList[index]--;
                      updateTotalPrice();
                    });
                  }: null,
                ),
                Text(
                  quantityList[index].toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed:  quantityList[index] < prize.stock ? () {
                    setState(() {
                      quantityList[index]++;
                      updateTotalPrice();
                    });
                  } : null,
                ),
              ],
            ) : null,
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                'Total : ${totalPrice*AppConfig.rate}ƒ / ${widget.selectedUser.balance*AppConfig.rate}ƒ',
                style: TextStyle(
                  fontSize: 18,
                  color: totalPrice <= widget.selectedUser.balance ? Colors.white : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              !btnLoading ? IconButton(
                onPressed: totalPrice <= widget.selectedUser.balance ? () async {
                  setState(() {
                    btnLoading = true;
                  });
                  bool res = true;
                  for (int i = 0; i < prizesList.length; i++){
                    if (quantityList[i] != 0 && res) {
                      await insertTransaction(widget.selectedUser.id, prizesList[i].id, quantityList[i] as double, 0);
                      prizesList[i].stock -= quantityList[i];
                      res = await updatePrize(prizesList[i]) && res;
                    }
                  }
                  if (res) {
                    res = await updateUserBalance(widget.selectedUser, widget.selectedUser.balance - totalPrice) && res;
                    widget.selectedUser.balance -= totalPrice;
                  }
                  setState(() {
                    btnLoading = false;
                  });
                  if (widget.showSuccess) {
                    await loadNewSuccess();
                  }
                  Navigator.pop(context, res);
                } : null,
                icon: const Icon(Icons.shopping_cart),
              ) :  const Center(child: CircularProgressIndicator(),)
            ],
          ),
        ),
      ),
    );
  }
}
