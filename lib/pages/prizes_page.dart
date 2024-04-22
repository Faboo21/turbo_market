import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/prize.dart';

import '../type/user.dart';

class Prizes extends StatefulWidget {
  const Prizes({super.key, required this.selectedUser});
  final User selectedUser;
  @override
  State<Prizes> createState() => _PrizesState();
}

class _PrizesState extends State<Prizes> {
  List<Prize> prizesList = [];
  List<int> quantityList = [];
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    loadPrizes();
  }

  Future<void> loadPrizes() async {
    List<Prize> resList = await getAllPrizes();
    setState(() {
      quantityList = List<int>.filled(resList.length, 0);
      prizesList = resList;
    });
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
                    prize.image,
                    fit: BoxFit.cover,
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
                  'Prix : ${prize.price*AppConfig.taux} ƒ',
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
                'Total : ${totalPrice*AppConfig.taux} ƒ / ${widget.selectedUser.balance*AppConfig.taux} ƒ',
                style: TextStyle(
                  fontSize: 18,
                  color: totalPrice <= widget.selectedUser.balance ? Colors.white : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: totalPrice <= widget.selectedUser.balance ? () async {
                  bool res = true;
                  for (int i = 0; i < prizesList.length; i++){
                    if (quantityList[i] != 0) {
                      res = await addTransaction(widget.selectedUser.id, prizesList[i].id, quantityList[i]) && res;
                    }
                  }
                  res = await updateUserBalance(widget.selectedUser, widget.selectedUser.balance - totalPrice) && res;
                  Navigator.pop(context, res);
                } : null,
                icon: const Icon(Icons.shopping_cart),
              )
            ],
          ),
        ),
      ),
    );
  }
}
