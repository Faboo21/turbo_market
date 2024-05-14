import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:turbo_market/pages/games_page.dart';
import 'package:turbo_market/pages/ranking_page.dart';
import 'package:turbo_market/pages/shop_page.dart';

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const RankingPage(),
    const ShopPage(),
    const GamesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Turbo Market'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/connexion");
            },
            icon: const Icon(Icons.lock_person),
          )
        ],
      ),
      body:
          _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesome.award),
            label: 'Classement',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesome.shopping_bag),
            label: 'Boutique',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesome.gamepad),
            label: 'Jeux',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}