import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:turbo_market/widget/games_page.dart';
import 'package:turbo_market/widget/ranking_page.dart';
import 'package:turbo_market/widget/shop_page.dart';

import '../api/api_request.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const RankingPage(viewOnly: false,),
    const ShopPage(scroll: false,),
    const GamesPage(viewMode: false,),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Turbo Market'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            if (constraints.maxWidth > 1500)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/showcase");
              },
              icon: const Icon(Icons.tv),
            ),
            IconButton(
              onPressed: () {
                _showEmailModal(context,"");
              },
              icon: const Icon(Icons.qr_code),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/connexion");
              },
              icon: const Icon(Icons.lock_person),
            ),
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
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showEmailModal(BuildContext context, String errorMessage) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Envoyer QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(fontFamily: "Nexa"),
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Adresse e-mail',
                  errorText: errorMessage.isNotEmpty ? errorMessage : null,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                if (isEmailValid(email)) {
                  if (await userExist(email)) {
                    bool res = await sendQr(email);
                    if (res) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email envoyé")));
                      Navigator.of(context).pop();
                    } else {
                      errorMessage = 'Probleme d\'envoi de l\'email';
                      Navigator.pop(context);
                      _showEmailModal(context, errorMessage);
                    }
                  } else {
                    errorMessage = 'E-mail non attribué';
                    Navigator.pop(context);
                    _showEmailModal(context, errorMessage);
                  }
                } else {
                  Navigator.pop(context);
                  _showEmailModal(context, "Adresse e-mail invalide");
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }


  bool isEmailValid(String email) {
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }
}