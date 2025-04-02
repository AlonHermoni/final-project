import 'package:flutter/material.dart';
import '../models/melody.dart';
import '../services/firestore_service.dart';
import 'add_melody_screen.dart';

class MelodyListScreen extends StatefulWidget {
  const MelodyListScreen({super.key});

  @override
  MelodyListScreenState createState() => MelodyListScreenState();
}

class MelodyListScreenState extends State<MelodyListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Melody> _melodies = [];
  bool _isLoading = true;
  String _selectedDifficulty = 'all';

  @override
  void initState() {
    super.initState();
    _loadMelodies();
  }

  Future<void> _loadMelodies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Melody> melodies;
      if (_selectedDifficulty == 'all') {
        melodies = await _firestoreService.getMelodies();
      } else {
        melodies = await _firestoreService
            .getMelodiesByDifficulty(_selectedDifficulty);
      }

      setState(() {
        _melodies = melodies;
      });
    } catch (e) {
      if (mounted) {
        // Check if widget is still mounted before using context
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading melodies: $e')),
        );
      }
    } finally {
      if (mounted) {
        // Check if widget is still mounted before setting state
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Melody Database'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedDifficulty = value;
              });
              _loadMelodies();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Difficulties'),
              ),
              const PopupMenuItem(
                value: 'beginner',
                child: Text('Beginner'),
              ),
              const PopupMenuItem(
                value: 'intermediate',
                child: Text('Intermediate'),
              ),
              const PopupMenuItem(
                value: 'advanced',
                child: Text('Advanced'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _melodies.isEmpty
              ? const Center(child: Text('No melodies found'))
              : ListView.builder(
                  itemCount: _melodies.length,
                  itemBuilder: (context, index) {
                    final melody = _melodies[index];
                    return ListTile(
                      title: Text(melody.name),
                      subtitle: Text(
                          'Difficulty: ${melody.difficulty}, Tempo: ${melody.tempo} BPM'),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          // TODO: Play the melody
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMelodyScreen(),
            ),
          );

          if (result == true) {
            _loadMelodies();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
