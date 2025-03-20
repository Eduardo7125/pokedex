import 'package:hive_flutter/hive_flutter.dart';
import '../Models/Pokemon.dart';
import '../core/notification_service.dart';

class HiveHelper {
  static const String favoritesBox = 'favorites';

  static Future<void> init() async {
    await Hive.openBox<Pokemon>(favoritesBox);
  }

  static Future<void> toggleFavorite(Pokemon pokemon) async {
    try {
      final box = Hive.box<Pokemon>(favoritesBox);

      if (box.containsKey(pokemon.id)) {
        await box.delete(pokemon.id);
        pokemon.isFavorite = false;
      } else {
        await box.put(pokemon.id, pokemon);
        pokemon.isFavorite = true;
        await NotificationService.instance
            .showFavoriteNotification(pokemon.name);
      }
    } catch (e) {
      throw Exception('Error al cambiar favorito: $e');
    }
  }

  static Future<List<Pokemon>> getFavorites() async {
    try {
      final box = Hive.box<Pokemon>(favoritesBox);
      return box.values.toList();
    } catch (e) {
      throw Exception('Error al obtener favoritos: $e');
    }
  }

  static Future<bool> isFavorite(Pokemon pokemon) async {
    try {
      final box = Hive.box<Pokemon>(favoritesBox);
      return box.containsKey(pokemon.id);
    } catch (e) {
      throw Exception('Error al verificar favorito: $e');
    }
  }
}
