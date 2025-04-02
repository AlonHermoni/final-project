import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/melody.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get melodies => _firestore.collection('melodies');

  // Get all melodies
  Future<List<Melody>> getMelodies() async {
    QuerySnapshot snapshot = await melodies.get();
    return snapshot.docs.map((doc) {
      return Melody.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Get melodies by difficulty
  Future<List<Melody>> getMelodiesByDifficulty(String difficulty) async {
    QuerySnapshot snapshot =
        await melodies.where('difficulty', isEqualTo: difficulty).get();
    return snapshot.docs.map((doc) {
      return Melody.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Add a new melody
  Future<DocumentReference> addMelody(Melody melody) async {
    return await melodies.add(
        melody.toFirestore()..['createdAt'] = FieldValue.serverTimestamp());
  }

  // Update a melody
  Future<void> updateMelody(Melody melody) async {
    if (melody.id == null) throw Exception('Cannot update melody with null ID');
    return await melodies.doc(melody.id).update(melody.toFirestore());
  }

  // Delete a melody
  Future<void> deleteMelody(String id) async {
    return await melodies.doc(id).delete();
  }
}
