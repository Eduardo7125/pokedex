import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/core/hive_helper.dart';
import 'package:flutter_pokedex/core/notification_service.dart';
import 'package:flutter_pokedex/core/pokemon_api.dart';

class PokemonProvider extends ChangeNotifier {
  final _api = PokemonApi();
  final _pokemonCache = <int, Pokemon>{};
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _filteredList = [];
  Set<String> _selectedTypes = {};
  String _currentSortOrder = 'number';
  bool _isLoading = false;
  String _error = '';
  bool _hasInternetConnection = false;
  double _loadingProgress = 0;

  List<Pokemon> get allPokemons => _allPokemons;
  List<Pokemon> get displayedPokemons => _filteredList;
  Set<String> get selectedTypes => _selectedTypes;
  bool get isLoading => _isLoading;
  String get error => _error;
  double get loadingProgress => _loadingProgress;
  bool get hasInternetConnection => _hasInternetConnection;

  Future<void> loadPokemons({bool refresh = false}) async {
    if (_allPokemons.isNotEmpty && !refresh) return;

    try {
      _isLoading = true;
      _error = '';
      _loadingProgress = 0;
      notifyListeners();

      await checkConnectivity();
      if (!_hasInternetConnection) {
        _error = 'No hay conexión a Internet';
        return;
      }

      final basicList = await _api.fetchAllPokemonBasic();
      _allPokemons = [];

      for (var i = 0; i < basicList.length; i++) {
        final basicPokemon = basicList[i];
        final pokemon =
            await _api.fetchPokemonDetails(basicPokemon['id'].toString());
        _allPokemons.add(pokemon);

        _loadingProgress = ((i + 1) / basicList.length) * 100;
        notifyListeners();
      }

      _filteredList = List.from(_allPokemons);
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar la lista de Pokémon';
      debugPrint('Error loading pokemon list: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    // This method is no longer needed with the new approach
    // but kept to maintain compatibility
    return;
  }

  Future<Pokemon> getPokemonDetails(int id) async {
    if (_pokemonCache.containsKey(id)) {
      return _pokemonCache[id]!;
    }

    try {
      final pokemon = await _api.fetchPokemonDetails(id.toString());
      await HiveHelper.updateFavoriteStatus(pokemon);
      _pokemonCache[id] = pokemon;
      return pokemon;
    } catch (e) {
      throw Exception('Error al cargar los detalles del Pokémon');
    }
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _hasInternetConnection = connectivityResult != ConnectivityResult.none;
    notifyListeners();
  }

  Future<void> updatePokemonFavorite(Pokemon pokemon) async {
    try {
      final wasNotFavorite = !pokemon.isFavorite;
      pokemon.isFavorite = !pokemon.isFavorite;
      notifyListeners();

      await HiveHelper.toggleFavorite(pokemon);

      if (wasNotFavorite && pokemon.isFavorite) {
        await NotificationService.instance
            .showFavoriteNotification(pokemon.name);
      }
    } catch (e) {
      pokemon.isFavorite = !pokemon.isFavorite;
      notifyListeners();
      throw e;
    }
  }

  Pokemon? getRandomPokemon() {
    if (_allPokemons.isEmpty) return null;
    final randomPokemon = (_allPokemons..shuffle()).first;
    return _pokemonCache[randomPokemon.id];
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
    if (sortBy != null) {
      _currentSortOrder = sortBy;
    }

    var filtered = List<Pokemon>.from(_allPokemons);

    if (searchQuery?.isNotEmpty ?? false) {
      filtered = filtered
          .where((pokemon) => pokemon.name.toLowerCase().contains(
                searchQuery!.toLowerCase(),
              ))
          .toList();
    }

    if (_selectedTypes.isNotEmpty) {
      filtered = filtered
          .where((pokemon) =>
              pokemon.types.any((type) => _selectedTypes.contains(type)))
          .toList();
    }

    if (_currentSortOrder == 'name') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else {
      filtered.sort((a, b) => a.id.compareTo(b.id));
    }

    _filteredList = filtered;
    notifyListeners();
  }

  void clearCache() {
    _pokemonCache.clear();
    notifyListeners();
  }
}
