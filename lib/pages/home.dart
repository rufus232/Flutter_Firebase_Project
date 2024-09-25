import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase/services/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller = TextEditingController();
  List<String> codesList = [];

  @override
  void initState() {
    super.initState();
    fetchCodes();
  }

  // Fonction pour récupérer les codes depuis Firestore
  void fetchCodes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('codes').get();
    setState(() {
      codesList = snapshot.docs.map((doc) => doc['code'] as String).toList();
    });
  }

  void openDialogCode() async {
    final code = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Code'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Ton code gojo',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('Cancel');
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Ajout du code à Firestore
                await FirebaseService().createCode(_controller.text);
                _controller.clear(); // Effacer le champ de texte
                fetchCodes(); // Mettre à jour la liste des codes
                Navigator.of(context).pop('OK');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour supprimer un code
  void deleteCode(String code) async {
    await FirebaseService().deleteCode(code);
    fetchCodes(); // Mettre à jour la liste après suppression
  }

  // Fonction pour copier le code dans le presse-papiers
  void copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code copié : $code'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Code'),
        backgroundColor: const Color.fromARGB(255, 4, 146, 228),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialogCode();
        },
        tooltip: 'Add Code',
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 4, 146, 228),
      ),
      body: codesList.isEmpty
          ? Center(child: CircularProgressIndicator()) // Affiche un indicateur de chargement
          : ListView.builder(
              itemCount: codesList.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      codesList[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            copyToClipboard(codesList[index]); // Appel de la fonction de copie
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteCode(codesList[index]); // Appel de la fonction de suppression
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
