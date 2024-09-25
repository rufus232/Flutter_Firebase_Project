import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {

  // Récupère la collection 'codes' depuis Firebase
  CollectionReference codes = FirebaseFirestore.instance.collection('codes');  

  // Fonction pour supprimer un code en fonction de sa valeur
  Future<void> deleteCode(String code) async {
    try {
      // Cherche le document contenant le code spécifié
      QuerySnapshot snapshot = await codes.where('code', isEqualTo: code).get();
      
      // Parcourt les documents trouvés et les supprime
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Erreur lors de la suppression du code : $e");
    }
  }

  // Créer un nouveau document dans la collection
  Future<DocumentReference> createCode(String code) async {
    final DocumentReference documentReference = await codes.add({
      'code': code,  
    });
    return documentReference;
  }

  // Récupérer tous les documents dans la collection
  Stream<QuerySnapshot> getCodes() {
    final getCodes = codes.snapshots();
    return getCodes;
  }
}
