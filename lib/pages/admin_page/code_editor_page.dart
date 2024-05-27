import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';

class CodeEditorPage extends StatefulWidget {
  const CodeEditorPage({super.key, required this.variables, required this.code});

  final List<String> variables;
  final String code;

  @override
  State<CodeEditorPage> createState() => _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage> {

  late CodeController controller;

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
${widget.code}

//[END code]''';

    controller = CodeController(
      language: dart,
      text: initialCode,
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
    );
    controller.readOnlySectionNames = {'readonly'};
    controller.foldOutsideSections(["code"]);
    controller.autocompleter.setCustomWords(widget.variables);
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
                  'Variables accessibles:',
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
                    children: widget.variables.map((e) => Padding(
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
          Navigator.pop(context, controller.fullText);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
