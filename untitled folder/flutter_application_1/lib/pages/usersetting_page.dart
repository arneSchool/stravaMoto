import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSettingsScreen extends StatefulWidget {
  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  String? profileImageUrl;

  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final carBrandController = TextEditingController();
  final carYearController = TextEditingController();
  final motoBrandController = TextEditingController();
  final motoYearController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _laadGebruikerData();
  }

  Future<void> _laadGebruikerData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'testuser';
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        profileImageUrl = data['profileImageUrl'];
        ageController.text = data['leeftijd']?.toString() ?? '';
        genderController.text = data['geslacht'] ?? '';
        carBrandController.text = data['auto_merk'] ?? '';
        carYearController.text = data['auto_jaar'] ?? '';
        motoBrandController.text = data['moto_merk'] ?? '';
        motoYearController.text = data['moto_jaar'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gebruikersinstellingen')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  // TODO: image picker
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null ? Icon(Icons.person, size: 40) : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildField("Leeftijd", ageController, keyboardType: TextInputType.number),
            _buildField("Geslacht", genderController),
            _buildField("Auto merk", carBrandController),
            _buildField("Auto jaar", carYearController),
            _buildField("Moto merk", motoBrandController),
            _buildField("Moto jaar", motoYearController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _opslaanGebruikerData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Instellingen opgeslagen")),
                );
              },
              child: Text("Opslaan"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _opslaanGebruikerData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'testuser';

    final data = {
      if (profileImageUrl != null && profileImageUrl!.isNotEmpty) 'profileImageUrl': profileImageUrl,
      if (ageController.text.isNotEmpty && int.tryParse(ageController.text) != null)
        'leeftijd': int.parse(ageController.text),
      if (genderController.text.isNotEmpty) 'geslacht': genderController.text,
      if (carBrandController.text.isNotEmpty) 'auto_merk': carBrandController.text,
      if (carYearController.text.isNotEmpty) 'auto_jaar': carYearController.text,
      if (motoBrandController.text.isNotEmpty) 'moto_merk': motoBrandController.text,
      if (motoYearController.text.isNotEmpty) 'moto_jaar': motoYearController.text,
    };

    await FirebaseFirestore.instance.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  @override
  void dispose() {
    ageController.dispose();
    genderController.dispose();
    carBrandController.dispose();
    carYearController.dispose();
    motoBrandController.dispose();
    motoYearController.dispose();
    super.dispose();
  }
}
