import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';
import 'package:turbo_market/api/game_request.dart';
import 'package:turbo_market/api/level_request.dart';
import 'package:turbo_market/api/prize_request.dart';
import 'package:turbo_market/api/stats_play_request.dart';
import 'package:turbo_market/api/transaction_request.dart';
import 'package:turbo_market/api/user_request.dart';
import 'package:turbo_market/type/api_type/game.dart';
import 'package:turbo_market/type/api_type/level.dart';
import 'package:turbo_market/type/api_type/prize.dart';
import 'package:turbo_market/type/api_type/stats_play.dart';
import 'package:turbo_market/type/api_type/success.dart';
import 'package:turbo_market/type/api_type/transaction.dart';
import 'package:turbo_market/type/api_type/user.dart';

class CodeEditorPage extends StatefulWidget {
  const CodeEditorPage({super.key, required this.success});

  final Success success;

  @override
  State<CodeEditorPage> createState() => _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage> {

  late CodeController controller;
  List<String> variables = [];

  List<StatsPlay> playsList = [];
  List<User> usersList = [];
  List<Transaction> transactionsList = [];
  List<Level> levelsList = [];
  List<Game> gamesList = [];
  List<Prize> prizesList = [];

  String extractCodeBetweenTags(String source, String tagName) {
    final startTag = '//[START $tagName]';
    final endTag = '//[END $tagName]';

    final startIndex = source.indexOf(startTag);
    final endIndex = source.indexOf(endTag);

    if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
      return '';
    }
    return source.substring(startIndex + startTag.length, endIndex).trim();
  }

  @override
  void initState() {
    super.initState();
    String initialCode = '''//[START readonly]
class User {// [START user]
  int id;
  String username;
  String email;
  int balance;
  String qr;
}// [END user]
class Game {// [START game]
  int id;
  String name;
  String rules;
  String createdAt;
  int price;
  int nbPlayersMin;
  int nbPlayersMax;
  String image;
}// [END game]
class Level {// [START level]
  int gameId;
  int step;
  int cashPrize;
  String libelle;
  int score;
  bool active;
}// [END level]
class Prize {// [START prize]
  int id;
  String name;
  String description;
  String createdAt;
  int price;
  String image;
  int stock;
}// [END prize]
class StatsPlay {// [START play]
  int playId;
  int gameid;
  int levStep;
  String parTime;
  int gain;
  int userId;
  int score;
  int cluster;
}// [END play]
class Transaction {// [START transaction]
  int traId;
  int usrId;
  int priId;
  String traTime;
  int traAmount;
  int payId;
}// [END transaction]

//Ecrire un code qui renvoi un boolean true si le succès est valide false sinon
//[END readonly]//[START code]
${widget.success.condition}

//[END code]''';

    controller = CodeController(
      language: dart,
      text: initialCode,
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
    );
    controller.readOnlySectionNames = {'readonly'};
    controller.foldOutsideSections(["code"]);
    List<String> params = [];
    switch (widget.success.type) {
      case 1:
        params += ["selectedUser", "playsList", "usersList", "gamesList", "levelsList"];
      case 2:
        params += ["selectedUser", "usersList", "prizesList", "transactionsList"];
      default :
        params += ["selectedUser", "playsList", "usersList", "gamesList", "levelsList", "prizesList", "transactionsList"];
    }
    setState(() {
      variables = params;
    });
    controller.autocompleter.setCustomWords(params);
    loadList();
  }

  Future<void> loadList() async {
    List<User> usersList2 = await getAllUsers();
    setState(() {
      usersList = usersList2;
    });
    if (widget.success.type != 2) {
      List<StatsPlay> playsList2 = await getAllStatsPlays();
      List<Level> levelsList2 = await getAllLevels();
      List<Game> gamesList2 = await getAllGames();
      setState(() {
        playsList = playsList2;
        levelsList = levelsList2;
        gamesList = gamesList2;
      });
    }
    if (widget.success.type != 1) {
      List<Prize> prizesList2 = await getAllPrizes();
      List<Transaction> transactionsList2 = await getAllTransactions();
      setState(() {
        prizesList = prizesList2;
        transactionsList = transactionsList2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Condition du succès'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Variables accessibles : ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: variables.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            e,
                            style: const TextStyle(
                              fontFamily: "Nexa",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          CodeTheme(
            data: CodeThemeData(styles: monokaiSublimeTheme),
            child: SingleChildScrollView(
              child: CodeField(
                textStyle: const TextStyle(fontFamily: "Nexa"),
                background: Colors.black,
                controller: controller,
                gutterStyle: const GutterStyle(
                  showErrors: true,
                  showFoldingHandles: true,
                  showLineNumbers: false,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String code = extractCodeBetweenTags(controller.fullText, "code");
          widget.success.condition = code;
          try {
            switch (widget.success.type) {
              case 1:
                widget.success.evaluatePlay(usersList.first, playsList, usersList, gamesList, levelsList);
              case 2:
                widget.success.evaluateTransaction(usersList.first, usersList, prizesList, transactionsList);
              default :
                widget.success.evaluate(usersList.first, playsList, usersList, gamesList, levelsList, prizesList, transactionsList);
            }
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le code ne compile pas")));
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
