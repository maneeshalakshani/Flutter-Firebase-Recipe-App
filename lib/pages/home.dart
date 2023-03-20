import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_integration/pages/recipe.dart';
import 'package:flutter/material.dart';

import '../models/auth.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              signOut();
            },
          )
        ],
      ),
      body: const Recipes(),
    );
  }
}
