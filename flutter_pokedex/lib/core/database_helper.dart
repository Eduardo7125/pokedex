import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pokemon.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        types TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        animatedUrl TEXT NOT NULL,
        height INTEGER NOT NULL,
        weight INTEGER NOT NULL,
        stats TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 1
      )
    ''');
  }

  Future<void> insertFavorite(Pokemon pokemon) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'id': pokemon.id,
        'name': pokemon.name,
        'types': jsonEncode(pokemon.types),
        'imageUrl': pokemon.imageUrl,
        'animatedUrl': pokemon.animatedUrl,
        'height': pokemon.height,
        'weight': pokemon.weight,
        'stats': jsonEncode(pokemon.stats),
        'isFavorite': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleFavorite(Pokemon pokemon) async {
    final db = await database;
    final isFav = await isFavorite(pokemon.id);

    if (isFav) {
      await removeFavorite(pokemon.id);
    } else {
      await insertFavorite(pokemon);
    }
  }

  Future<bool> isFavorite(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  String _statsToJson(Map<String, int> stats) {
    return stats.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  Map<String, int> _statsFromJson(String json) {
    final Map<String, int> stats = {};
    final List<String> pairs = json.split(',');
    for (var pair in pairs) {
      final parts = pair.split(':');
      stats[parts[0]] = int.parse(parts[1]);
    }
    return stats;
  }

  Future<List<Pokemon>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return Pokemon.fromMap(maps[i]);
    });
  }
}
