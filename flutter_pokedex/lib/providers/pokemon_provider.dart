import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
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
      _pokemons = newPokemons;
    } catch (e) {
      _error = 'Error al cargar los Pokémon: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Pokemon getRandomPokemon() {
    final random = Random();
    return pokemons[random.nextInt(pokemons.length)];
  }
}
