import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/core/hive_helper.dart';
import 'package:flutter_pokedex/core/pokemon_api.dart';

class PokemonProvider extends ChangeNotifier {
  final _api = PokemonApi();
  List<Pokemon> _originalPokemons = [];
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _displayedPokemons = [];
  bool _isLoading = false;
  String _error = '';

  static const int _itemsPerPage = 50;
  int _currentPage = 0;

  Set<String> _selectedTypes = <String>{};

  // Add sortOrder field
  String _currentSortOrder = 'number';

  List<Pokemon> get allPokemons => _allPokemons;
  List<Pokemon> get displayedPokemons => _displayedPokemons;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get canLoadMore => _currentPage * _itemsPerPage < _allPokemons.length;
  Set<String> get selectedTypes => _selectedTypes;

  Future<void> loadPokemons({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = '';
      if (refresh) {
        _currentPage = 0;
        _displayedPokemons = [];
      }
      notifyListeners();

      if (_originalPokemons.isEmpty) {
        final newPokemons = await _api.getPokemons();
        for (var pokemon in newPokemons) {
          await HiveHelper.updateFavoriteStatus(pokemon);
        }
        _originalPokemons = newPokemons;
        _allPokemons = List.from(_originalPokemons);
      }

      loadNextPage();
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
    return allPokemons[random.nextInt(allPokemons.length)];
  }

  void loadNextPage() {
    if (!canLoadMore) return;

    final start = _currentPage * _itemsPerPage;
    final end = math.min(
      (_currentPage + 1) * _itemsPerPage,
      _allPokemons.length,
    );

    _displayedPokemons.addAll(_allPokemons.sublist(start, end));
    _currentPage++;
    notifyListeners();
  }

  void toggleType(String type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    applyFilters(sortBy: _currentSortOrder);
  }

  void applyFilters({String? searchQuery, String? sortBy}) {
    _currentPage = 0;
    _displayedPokemons = [];

    // Store sort order if provided
    if (sortBy != null) {
      _currentSortOrder = sortBy;
    }

    // Start with original list
    _allPokemons = List.from(_originalPokemons);

    // Apply search filter
    if (searchQuery?.isNotEmpty ?? false) {
      _allPokemons =
          _allPokemons
              .where(
                (pokemon) => pokemon.name.toLowerCase().contains(
                  searchQuery!.toLowerCase(),
                ),
              )
              .toList();
    }

    // Apply type filter
    if (_selectedTypes.isNotEmpty) {
      _allPokemons =
          _allPokemons
              .where(
                (pokemon) =>
                    pokemon.types.any((type) => _selectedTypes.contains(type)),
              )
              .toList();
    }

    // Apply current sort order
    if (_currentSortOrder == 'name') {
      _allPokemons.sort((a, b) => a.name.compareTo(b.name));
    } else {
      _allPokemons.sort((a, b) => a.id.compareTo(b.id));
    }

    loadNextPage();
    notifyListeners();
  }
}
