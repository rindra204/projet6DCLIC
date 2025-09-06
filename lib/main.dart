// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'modele/blocnote.dart';
import 'db/database.dart';
import 'screens/login.dart';
import 'screens/note_liste.dart';
import 'screens/edit_note.dart';
import 'dart:io'; // pour savoir si on est sur Windows/Linux/macOS
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // pour SQLite sur desktop

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialisation SQLite FFI pour desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: MaterialApp(
        title: 'Notes App',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const SplashOrLogin(),
      ),
    );
  }
}

class AuthProvider with ChangeNotifier {
  String? _username;
  String? get username => _username;

  Future<bool> login(String username, String password) async {
    final db = DatabaseHelper.instance;
    final user = await db.getUserByUsername(username);
    final hash = sha256.convert(utf8.encode(password)).toString();
    if (user == null) {
      await db.insertUser({'username': username, 'password_hash': hash});
      _username = username;
      notifyListeners();
      return true;
    }
    if (user['password_hash'] == hash) {
      _username = username;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _username = null;
    notifyListeners();
  }
}

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    final db = DatabaseHelper.instance;
    final maps = await db.getAllNotes();
    _notes = maps.map((m) => Note.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    final db = DatabaseHelper.instance;
    final id = await db.insertNote(note.toMap());
    note.id = id;
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    final db = DatabaseHelper.instance;
    await db.updateNote(note.toMap());
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    final db = DatabaseHelper.instance;
    await db.deleteNote(id);
    await loadNotes();
  }
}

class SplashOrLogin extends StatefulWidget {
  const SplashOrLogin({super.key});

  @override
  State<SplashOrLogin> createState() => _SplashOrLoginState();
}

class _SplashOrLoginState extends State<SplashOrLogin> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await DatabaseHelper.instance.database;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const LoginScreen();
  }
}
