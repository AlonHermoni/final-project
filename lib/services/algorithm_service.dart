import 'dart:convert';
import 'package:http/http.dart' as http;

class MelodyMatchResult {
  final double score;
  final Map<String, double> algorithmScores;
  final String feedback;

  MelodyMatchResult({
    required this.score,
    required this.algorithmScores,
    required this.feedback,
  });

  factory MelodyMatchResult.fromJson(Map<String, dynamic> json) {
    return MelodyMatchResult(
      score: json['score'].toDouble(),
      algorithmScores: Map<String, double>.from(json['algorithm_scores']),
      feedback: json['feedback'],
    );
  }
}

class AlgorithmService {
  // TODO: Replace with your actual server URL when deployed
  final String serverUrl = 'http://localhost:5000';

  // Compare two melodies using server-side algorithms
  Future<MelodyMatchResult> compareMelodies(
      {required List<int> originalMidiNotes,
      required List<int> userMidiNotes}) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/compare'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'original_midi': originalMidiNotes,
          'user_midi': userMidiNotes,
        }),
      );

      if (response.statusCode == 200) {
        return MelodyMatchResult.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to compare melodies: ${response.statusCode}');
      }
    } catch (e) {
      // Temporary fallback to local basic comparison while server is in development
      return _localBasicComparison(originalMidiNotes, userMidiNotes);
    }
  }

  // A simple local comparison method as fallback until server is ready
  MelodyMatchResult _localBasicComparison(List<int> original, List<int> user) {
    int matches = 0;
    int partialMatches = 0;

    // Basic comparison (similar to your current grading logic)
    for (int i = 0; i < original.length && i < user.length; i++) {
      if (original[i] == user[i]) {
        matches++;
      } else if (original.contains(user[i])) {
        partialMatches++;
      }
    }

    // Calculate a score from 0-100
    double finalScore =
        (matches * 10 + partialMatches * 5) / (original.length * 10) * 100;

    // Cap at 100
    finalScore = finalScore > 100 ? 100 : finalScore;

    return MelodyMatchResult(
      score: finalScore,
      algorithmScores: {
        'local_basic': finalScore,
        'dtw': 0.0, // Will be calculated on server when ready
        'levenshtein': 0.0,
        'lcs': 0.0,
        'cosine': 0.0,
      },
      feedback: 'Server-side algorithms not available. Using basic comparison.',
    );
  }
}
