import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'login.dart';
import 'edit_note.dart';
// ignore: unused_import
import '../modele/blocnote.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  @override
  Widget build(BuildContext context) {
    final notesProv = Provider.of<NotesProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
        backgroundColor: Colors.purple[700],
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notesProv.loadNotes(),
        child: LayoutBuilder(builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 800
              ? 3
              : (constraints.maxWidth > 600 ? 2 : 1);
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: notesProv.notes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddCard(context);
              }
              final note = notesProv.notes[index - 1];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => NoteEditScreen(note: note))),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.deepPurple)),
                          const SizedBox(height: 8),
                          Expanded(
                              child: Text(note.content,
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis)),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat.yMMMd()
                                    .add_jm()
                                    .format(note.updatedAt)),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Supprimer ?'),
                                        content: const Text(
                                            'Voulez-vous vraiment supprimer cette note ?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Annuler')),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Supprimer')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await notesProv.deleteNote(note.id!);
                                    }
                                  },
                                )
                              ])
                        ]),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) => Card(
        color: Colors.indigo.shade50,
        child: InkWell(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const NoteEditScreen())),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.add, size: 48),
              SizedBox(height: 8),
              Text('Ajouter une note')
            ]),
          ),
        ),
      );
}
