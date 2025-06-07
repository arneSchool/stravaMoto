import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'usersetting_page.dart'; // importeer je settingspagina

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int? leeftijd;
  String? geslacht;
  String? autoMerk;
  String? autoJaar;
  String? motoMerk;
  String? motoJaar;

  @override
  void initState() {
    super.initState();
    _haalGebruikerInfoOp();
  }

  Future<void> _haalGebruikerInfoOp() async {
    // final uid = FirebaseAuth.instance.currentUser?.uid ?? 'testuser';
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();


    

    if (doc.exists) {
      print("in doc.exists");
      final data = doc.data()!;
      setState(() {
        leeftijd = data['leeftijd'] ?? -1;
        geslacht = data['geslacht'];
        autoMerk = data['auto_merk'];
        autoJaar = data['auto_jaar'];
        motoMerk = data['moto_merk'];
        motoJaar = data['moto_jaar'];
      });
    }else{
      print("doc voor gebruiker $uid bestaat niet in users");
      setState(() {
        leeftijd = -1;
      });
    }
  }

  void _uitloggen() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Uitloggen'),
        content: Text('Ben je zeker dat je wilt uitloggen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Uitloggen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mijn Profiel')),
      body: Center(
        child: leeftijd == null
            ? CircularProgressIndicator()
            : Card(
                margin: EdgeInsets.all(16),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Leeftijd: $leeftijd jaar', style: TextStyle(fontSize: 18)),
                      if (geslacht != null)
                        Text('Geslacht: $geslacht', style: TextStyle(fontSize: 18)),
                      if (autoMerk != null || autoJaar != null)
                        Text('Auto: ${autoMerk ?? ""} ${autoJaar ?? ""}', style: TextStyle(fontSize: 18)),
                      if (motoMerk != null || motoJaar != null)
                        Text('Moto: ${motoMerk ?? ""} ${motoJaar ?? ""}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => UserSettingsScreen()),
                          ).then((_) {
                            _haalGebruikerInfoOp(); // opnieuw ophalen na aanpassen
                          });
                        },
                        icon: Icon(Icons.settings),
                        label: Text("Instellingen aanpassen"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _uitloggen,
                        icon: Icon(Icons.logout),
                        label: Text("Uitloggen"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
