import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'note_liste.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        centerTitle: true, // centre le titre
        title: const Text('Connexion'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: isWide ? 500 : double.infinity,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Image en haut
                    Image.asset(
                      'assets/notes.jpg',
                      height: 120,
                    ),
                    const SizedBox(height: 20),

                    // Champ Nom d'utilisateur
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nom d\'utilisateur'),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Entrez le nom d\'utilisateur'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Champ Mot de passe
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Mot de passe'),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Entrez le mot de passe'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Message d'erreur
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),

                    // Bouton violet
                    _loading
                        ? const CircularProgressIndicator()
                        : Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple, // violet
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                  ),
                                  onPressed: _submit,
                                  child: const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok =
        await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text.trim());
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = 'Nom d\'utilisateur ou mot de passe incorrect');
      return;
    }
    await Provider.of<NotesProvider>(context, listen: false).loadNotes();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NotesListScreen()));
  }
}
