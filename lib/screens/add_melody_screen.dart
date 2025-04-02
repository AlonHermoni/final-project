import 'package:flutter/material.dart';
import '../models/melody.dart';
import '../services/firestore_service.dart';

class AddMelodyScreen extends StatefulWidget {
  const AddMelodyScreen({super.key});

  @override
  AddMelodyScreenState createState() => AddMelodyScreenState();
}

class AddMelodyScreenState extends State<AddMelodyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _midiNotesController = TextEditingController();
  final _tempoController = TextEditingController(text: '120');
  String _difficulty = 'beginner';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _midiNotesController.dispose();
    _tempoController.dispose();
    super.dispose();
  }

  Future<void> _saveMelody() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse MIDI notes from comma-separated string
      final midiNotesString = _midiNotesController.text.trim();
      final midiNotes = midiNotesString
          .split(',')
          .map((note) => int.parse(note.trim()))
          .toList();

      // Create melody object
      final melody = Melody(
        name: _nameController.text.trim(),
        difficulty: _difficulty,
        tempo: int.parse(_tempoController.text.trim()),
        midiNotes: midiNotes,
      );

      // Save to Firestore
      final firestoreService = FirestoreService();
      await firestoreService.addMelody(melody);

      if (!mounted) return;

      // Show success message and go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Melody saved successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving melody: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Melody'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Melody Name',
                      hintText: 'Enter a name for this melody',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _difficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty Level',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'beginner',
                        child: Text('Beginner'),
                      ),
                      DropdownMenuItem(
                        value: 'intermediate',
                        child: Text('Intermediate'),
                      ),
                      DropdownMenuItem(
                        value: 'advanced',
                        child: Text('Advanced'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _difficulty = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tempoController,
                    decoration: const InputDecoration(
                      labelText: 'Tempo (BPM)',
                      hintText: 'Enter the tempo in beats per minute',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a tempo';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _midiNotesController,
                    decoration: const InputDecoration(
                      labelText: 'MIDI Notes',
                      hintText:
                          'Enter comma-separated MIDI notes (e.g., 60,62,64,65,67,69,71,72)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter MIDI notes';
                      }
                      try {
                        value
                            .trim()
                            .split(',')
                            .map((note) => int.parse(note.trim()))
                            .toList();
                        return null;
                      } catch (e) {
                        return 'Please enter valid numbers separated by commas';
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveMelody,
                    child: const Text('Save Melody'),
                  ),
                ],
              ),
            ),
    );
  }
}
