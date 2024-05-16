import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/prize.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});
  @override
  State<ShopPage> createState() => _ShopState();
}

class _ShopState extends State<ShopPage> {
  List<Prize> prizesList = [];

  @override
  void initState() {
    super.initState();
    loadPrizes();
  }

  Future<void> loadPrizes() async {
    List<Prize> resList = await getAllPrizes();
    setState(() {
      prizesList = resList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: prizesList.length,
      itemBuilder: (context, index) {
        Prize prize = prizesList[index];
        return ListTile(
          leading:
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                prize.image,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: prize.stock == 0 ? Colors.red : prize.stock <= 5? Colors.orangeAccent : null
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                'Prix : ${prize.price*AppConfig.rate} ƒ',
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
          trailing: prize.stock == 0 ? const Icon(Icons.not_interested, color: Colors.red,) : prize.stock < 5 ? const Icon(Icons.warning_amber, color: Colors.orangeAccent,) : null,
        );
      },
    );
  }
}
