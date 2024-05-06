import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/rarity.dart';
import '../type/title.dart';

class TitlesPage extends StatefulWidget {
  const TitlesPage({super.key});

  @override
  State<TitlesPage> createState() => _TitlesPageState();
}

class _TitlesPageState extends State<TitlesPage> {
  List<UserTitle> _titles = [];

  @override
  void initState() {
    _loadTitles();
    super.initState();
  }

  Future<void> _loadTitles() async {
    List<UserTitle> titles = await getAllTitles();
    titles.sort((a, b) => b.rarity.value.compareTo(a.rarity.value));
    setState(() {
      _titles = titles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Titres'),
      ),
      body: _titles.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _titles.length,
              itemBuilder: (context, index) {
                UserTitle title = _titles[index];
                return ExpansionTile(
                  leading: SizedBox(
                    width: 50,
                    child: AspectRatio(
                      aspectRatio: 1, // Aspect ratio 1:1 for square image
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          title.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: Text(title.libelle, style: TextStyle(color: title.rarity.color),),
                  children: [
                    ListTile(
                      title: Text('Rareté: ${title.rarity.toString().split('.').last}'),
                      subtitle: Text('Obtention: ${title.rules}'),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
