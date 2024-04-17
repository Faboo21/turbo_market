import 'package:flutter/material.dart';
import '../type/user.dart';

class WinnerChoicePage extends StatefulWidget {
  const WinnerChoicePage({super.key, required this.playersList});
  final List<User?> playersList;

  @override
  State<WinnerChoicePage> createState() => _WinnerChoicePageState();
}

class _WinnerChoicePageState extends State<WinnerChoicePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choix du gagnant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body:
      ListView.builder(
        itemCount: widget.playersList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(widget.playersList[index]!.username),
              onTap: () async {
                Navigator.pop(context, widget.playersList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
