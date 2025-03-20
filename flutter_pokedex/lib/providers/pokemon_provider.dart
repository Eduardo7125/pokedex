import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/core/hive_helper.dart';
import 'package:flutter_pokedex/core/pokemon_api.dart';

class PokemonProvider extends ChangeNotifier {
  final _api = PokemonApi();
  List<Pokemon> _pokemons = [];
  bool _isLoading = false;
  String _error = '';

  List<Pokemon> get pokemons => _pokemons;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadPokemons({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final newPokemons = await _api.getPokemons();

      // Update favorite status for all pokemons
      for (var pokemon in newPokemons) {
        await HiveHelper.updateFavoriteStatus(pokemon);
      }

      _pokemons = newPokemons;
    } catch (e) {
      _error = 'Error al cargar los Pokémon: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePokemonFavorite(Pokemon pokemon) async {
    await HiveHelper.toggleFavorite(pokemon);
    notifyListeners();
  }

  Pokemon getRandomPokemon() {
    final random = Random();
    return pokemons[random.nextInt(pokemons.length)];
  }
}
