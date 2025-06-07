import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/auth/login_page.dart';
import '../main.dart'; // MainScreen zit daar

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Debug print zodat je weet wat er gebeurt
        print("AuthGate status: connection=${snapshot.connectionState}, user=${snapshot.data}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Er ging iets mis: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData) {
          print("gebruiker is ingelogd, main screen tonen");
          return MainScreen(); // gebruiker is ingelogd
        }

        return LoginPage(); // gebruiker is niet ingelogd
      },
    );
  }
}
