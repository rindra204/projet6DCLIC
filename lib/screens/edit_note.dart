import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../modele/blocnote.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;
  const NoteEditScreen({this.note, super.key});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Éditer la note' : 'Nouvelle note'),
        backgroundColor: Colors.purple[700],
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Entrez un titre' : null),
            const SizedBox(height: 12),
            Expanded(
                child: TextFormField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(labelText: 'Contenu'),
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // couleur violet
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // couleur violet
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ])
          ]),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final notesProv = Provider.of<NotesProvider>(context, listen: false);
    final now = DateTime.now();
    if (widget.note == null) {
      final n = Note(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          createdAt: now,
          updatedAt: now);
      await notesProv.addNote(n);
    } else {
      final n = widget.note!..title = _titleCtrl.text.trim();
      n.content = _contentCtrl.text.trim();
      n.updatedAt = now;
      await notesProv.updateNote(n);
    }
    setState(() => _saving = false);
    Navigator.pop(context);
  }
}
