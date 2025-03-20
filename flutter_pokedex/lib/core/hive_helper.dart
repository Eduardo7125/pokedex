import 'package:hive_flutter/hive_flutter.dart';
import '../Models/Pokemon.dart';
import '../core/notification_service.dart';

class HiveHelper {
  static const String favoritesBox = 'favorites';

  static Future<void> init() async {
    await Hive.openBox<Pokemon>(favoritesBox);
  }

  static Future<bool> isFavorite(Pokemon pokemon) async {
    final box = Hive.box<Pokemon>(favoritesBox);
    return box.containsKey(pokemon.id);
  }

  static Future<void> toggleFavorite(Pokemon pokemon) async {
    final box = Hive.box<Pokemon>(favoritesBox);

    if (box.containsKey(pokemon.id)) {
      await box.delete(pokemon.id);
      pokemon.isFavorite = false;
    } else {
      pokemon.isFavorite = true;
      await box.put(pokemon.id, pokemon);
      await NotificationService.instance.showFavoriteNotification(pokemon.name);
    }
  }

  static Future<void> updateFavoriteStatus(Pokemon pokemon) async {
    final box = Hive.box<Pokemon>(favoritesBox);
    pokemon.isFavorite = box.containsKey(pokemon.id);
  }

  static Future<List<Pokemon>> getFavorites() async {
    try {
      final box = Hive.box<Pokemon>(favoritesBox);
      return box.values.toList();
    } catch (e) {
      throw Exception('Error al obtener favoritos: $e');
    }
  }
}
