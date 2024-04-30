import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';

import '../type/user.dart';
import '../type/user_rank.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List<UserRank> playersList = [];

  @override
  void initState() {
    _loadPlayersList();
    super.initState();
  }

  void _loadPlayersList() async {
    setState(() {
      playersList = [];
    });
    List<User> users = await getAllUsers();
    for (var user in users) {
      setState(() {
        playersList.add(UserRank(id: user.id, username: user.username, balance: user.balance));
      });
    }
    playersList.sort((a, b) => b.balance.compareTo(a.balance));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Turbo Market'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [IconButton(onPressed: () {Navigator.pushNamed(context, "/connexion");}, icon: const Icon(Icons.lock_person))],
      ),
      body:
          Column(
            children: [
              SizedBox(
                height: 800,
                child: ListView.builder(
                  itemCount: playersList.length,
                  itemBuilder: (context, index) {
                    UserRank player = playersList[index];
                    return ExpansionTile(
                      leading: Text((index+1).toString(), style: TextStyle(fontSize: 15, color: index == 0 ? Colors.yellow : index == 1 ? Colors.grey : index == 2 ? Colors.brown : Colors.white),),
                      title: Text(player.username),
                      children: [
                        ListTile(title: Text(player.balance.toString()))
                      ],
                    );
                  }
                ),
              )
            ],
          ),
    );
  }
}
