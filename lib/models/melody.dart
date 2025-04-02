import 'package:cloud_firestore/cloud_firestore.dart';

class Melody {
  final String? id;
  final String name;
  final String difficulty;
  final int tempo;
  final List<int> midiNotes;
  final DateTime? createdAt;

  Melody({
    this.id,
    required this.name,
    required this.difficulty,
    required this.tempo,
    required this.midiNotes,
    this.createdAt,
  });

  // Convert Firestore document to Melody object
  factory Melody.fromFirestore(Map<String, dynamic> data, String docId) {
    return Melody(
      id: docId,
      name: data['name'] as String,
      difficulty: data['difficulty'] as String,
      tempo: data['tempo'] as int,
      midiNotes: List<int>.from(data['midiNotes']),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert Melody object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'difficulty': difficulty,
      'tempo': tempo,
      'midiNotes': midiNotes,
    };
  }
}
