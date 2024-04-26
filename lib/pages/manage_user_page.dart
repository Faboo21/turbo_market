import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import '../type/user.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<User> userList = [];
  List<User> filteredUserList = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    loadUsers();
    super.initState();
  }

  void loadUsers() async {
    List<User> resList = await getAllUsers();
    setState(() {
      userList = resList;
      filteredUserList = userList;
    });
  }

  void filterUsers(String query) {
    List<User> filteredUsers = userList.where((user) => user.username.toLowerCase().contains(query.toLowerCase()) || user.email.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredUserList = filteredUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterUsers,
              decoration: const InputDecoration(
                labelText: 'Rechercher par username / email',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUserList.length,
              itemBuilder: (context, index) {
                User user = filteredUserList[index];
                TextEditingController usernameController = TextEditingController(text: user.username);
                TextEditingController emailController = TextEditingController(text: user.email);
                TextEditingController balanceController = TextEditingController(text: user.balance.toString());

                final formKey = GlobalKey<FormState>();

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(user.username),
                    children: [
                      Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: usernameController,
                                onChanged: (value) => user.username = value,
                                decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le nom d\'utilisateur';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: emailController,
                                onChanged: (value) => user.email = value,
                                decoration: const InputDecoration(labelText: 'Email'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer l\'adresse email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Adresse email invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: balanceController,
                                onChanged: (value) => user.balance = double.parse(value),
                                decoration: const InputDecoration(labelText: 'Solde'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Merci d\'entrer le solde';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Valeur invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        updateUserManage(user);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmationDialog(user),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void updateUserManage(User user) async {
    bool res = await updateUser(user);
    if (res) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Utilisateur mis à jour avec succès")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour de l'utilisateur")));
    }
  }

  void showDeleteConfirmationDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer l\'utilisateur ${user.username} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                deleteUserManage(user);
              },
              child: const Text('Oui',style: TextStyle(color: Colors.red),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
              },
              child: const Text('Non'),
            ),
          ],
        );
      },
    );
  }

  void deleteUserManage(User user) async {
    bool res = await deleteUser(user);
    if (res) {
      setState(() {
        userList.remove(user);
        filteredUserList.remove(user);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Utilisateur supprimé avec succès")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème suppression de l'utilisateur")));
    }
  }
}
