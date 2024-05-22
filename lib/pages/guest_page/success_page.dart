import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:turbo_market/type/api_type/rarity.dart';
import 'package:turbo_market/type/api_type/success.dart';
import 'package:turbo_market/api/rarity_request.dart';
import 'package:turbo_market/api/success_request.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> with TickerProviderStateMixin {
  List<Success> successList = [];
  List<Rarity> rarities = [];

  late GifController _controller;

  @override
  void initState() {
    setState(() {
      _controller = GifController(vsync: this);
    });
    _loadSuccess();
    super.initState();
  }

  Future<void> _loadSuccess() async {
    List<Success> success = await getAllSuccess();
    List<Rarity> raritiesList = await getAllRarities();
    success.sort((a, b) => b.rarity.value.compareTo(a.rarity.value));
    setState(() {
      successList = success;
      rarities = raritiesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Succès'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: successList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: successList.length,
              itemBuilder: (context, index) {
                Success success = successList[index];
                return ExpansionTile(
                  leading: success.rarity.id != rarities.last.id ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius
                              .circular(50),
                          child: Container(
                            width: 30,
                            height: 30,
                            color: success.rarity.displayColor,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              child:
                              Image.network(
                                "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                      ]
                  ) :
                  Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius
                              .circular(50),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red,
                                  Colors.orange,
                                  Colors.yellow,
                                  Colors.green,
                                  Colors.blue,
                                  Colors.indigo,
                                  Colors.purple,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              child:
                              Image.network(
                                "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child:
                            Gif(
                              image: const AssetImage(
                                  "images/giphy.gif"),
                              controller: _controller,
                              // if duration and fps is null, original gif fps will be used.
                              //fps: 30,
                              //duration: const Duration(seconds: 3),
                              autostart: Autostart.loop,
                              placeholder: (context) =>
                              const Text('Loading...'),
                              onFetchCompleted: () {
                                _controller.reset();
                                _controller.forward();
                              },
                            ),
                          ),
                        )
                      ]
                  ),
                  title: Text(success.libelle, style: TextStyle(color: success.rarity.displayColor),),
                  children: [
                    ListTile(
                      title: Text('Rareté: ${success.rarity.libelle}'),
                      subtitle: Text('Obtention: ${success.rules}'),
                    ),
                  ],
                );
              },
            ),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}
