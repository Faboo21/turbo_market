import 'package:flutter/material.dart';
import 'package:turbo_market/widget/games_page.dart';
import 'package:turbo_market/widget/ranking_page.dart';
import 'package:turbo_market/widget/shop_page.dart';

class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 800) {
            return const Row(
              children: [
                SizedBox(
                  width: 400,
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Classement 24h",
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      Divider(),
                      Expanded(child: RankingPage(viewOnly: true)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 400,
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Shop",
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      Divider(),
                      Expanded(child: ShopPage(scroll: true)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Jeux",
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      Divider(),
                      Expanded(child: GamesPage(viewMode: true,)),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text(
                "Vue ordinateur uniquement",
                style: TextStyle(fontSize: 24),
              ),
            );
          }
        },
      ),
    );
  }
}
