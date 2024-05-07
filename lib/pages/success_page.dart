import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import '../type/success.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  List<Success> successList = [];

  @override
  void initState() {
    _loadSuccess();
    super.initState();
  }

  Future<void> _loadSuccess() async {
    List<Success> success = await getAllSuccess();
    success.sort((a, b) => b.rarity.value.compareTo(a.rarity.value));
    setState(() {
      successList = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Succès'),
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
                  leading: SizedBox(
                    width: 50,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          success.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
}
