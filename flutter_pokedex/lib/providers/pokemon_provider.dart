import 'dart:math';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/core/hive_helper.dart';
import 'package:flutter_pokedex/core/notification_service.dart';
import 'package:flutter_pokedex/core/pokemon_api.dart';

class PokemonProvider extends ChangeNotifier {
  static const int _maxPokemons = 1008; // Actual available Pokémon count
  static const int _itemsPerPage = 20;
  final _api = PokemonApi();
  final _pokemonCache = <int, Pokemon>{};

  List<Pokemon> _originalPokemons = [];
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _displayedPokemons = [];
  Set<String> _selectedTypes = {};
  String _currentSortOrder = 'number';
  int _currentPage = 0;
  int _loadingProgress = 0;
  bool _isLoading = false;
  String _error = '';
  bool _hasInternetConnection = true;

  List<Pokemon> get displayedPokemons => _displayedPokemons;
  List<Pokemon> get allPokemons => _allPokemons;
  Set<String> get selectedTypes => _selectedTypes;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get loadingProgress => _loadingProgress;
  bool get canLoadMore => _currentPage * _itemsPerPage < _allPokemons.length;

  static Future<Pokemon?> _fetchPokemonDetails(
    Map<String, dynamic> args,
  ) async {
    try {
      final response = await http.get(Uri.parse(args['url']));
      if (response.statusCode == 200) {
        return Pokemon.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching pokemon: $e');
      return null;
    }
  }

  Future<void> loadPokemons({bool refresh = false}) async {
    if (_isLoading) return;

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

      if (_originalPokemons.isEmpty || refresh) {
        _originalPokemons = [];
        const batchSize = 50; // Increased batch size
        final totalBatches = (_maxPokemons / batchSize).ceil();

        for (var batch = 0; batch < totalBatches; batch++) {
          final start = batch * batchSize + 1;
          final end = math.min(start + batchSize, _maxPokemons + 1);

          final futures = List.generate(
            end - start,
            (index) => compute(_fetchPokemonDetails, {
              'url': '${PokemonApi.baseUrl}/pokemon/${start + index}',
            }),
          );

          final results = await Future.wait(futures);
          final validResults = results.whereType<Pokemon>().toList();

          _originalPokemons.addAll(validResults);
          for (var pokemon in validResults) {
            _pokemonCache[pokemon.id] = pokemon;
            await HiveHelper.updateFavoriteStatus(pokemon);
          }

          _loadingProgress = ((batch + 1) / totalBatches * 100).round();
          _allPokemons = List.from(_originalPokemons);
          _displayedPokemons =
              _allPokemons.take((batch + 1) * batchSize).toList();
          notifyListeners();
        }
      }

      _displayedPokemons = List.from(_allPokemons);
      _currentPage = (_displayedPokemons.length / _itemsPerPage).ceil();
    } catch (e) {
      _error = 'Error al cargar los Pokémon';
      debugPrint('Error loading pokemon: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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

      // Guardar en Hive
      await HiveHelper.toggleFavorite(pokemon);

      if (wasNotFavorite && pokemon.isFavorite) {
        await NotificationService.instance.showFavoriteNotification(
          pokemon.name,
        );
      }
    } catch (e) {
      pokemon.isFavorite = !pokemon.isFavorite;
      notifyListeners();
      throw e;
    }
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

    // Pre-fetch next batch
    _prefetchNextBatch();
  }

  Future<void> _prefetchNextBatch() async {
    final nextStart = (_currentPage + 1) * _itemsPerPage;
    if (nextStart >= _allPokemons.length) return;

    final futures = <Future>[];
    for (int i = nextStart; i < nextStart + _itemsPerPage; i++) {
      if (i < _allPokemons.length && !_pokemonCache.containsKey(i + 1)) {
        futures.add(_api.getPokemonDetails((i + 1).toString()));
      }
    }

    if (futures.isNotEmpty) {
      final newPokemons = await Future.wait(futures);
      for (var pokemon in newPokemons) {
        _pokemonCache[pokemon.id] = pokemon;
      }
    }
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

    if (sortBy != null) {
      _currentSortOrder = sortBy;
    }

    var filtered = List<Pokemon>.from(_originalPokemons);

    if (searchQuery?.isNotEmpty ?? false) {
      filtered =
          filtered
              .where(
                (pokemon) => pokemon.name.toLowerCase().contains(
                  searchQuery!.toLowerCase(),
                ),
              )
              .toList();
    }

    if (_selectedTypes.isNotEmpty) {
      filtered =
          filtered
              .where(
                (pokemon) =>
                    pokemon.types.any((type) => _selectedTypes.contains(type)),
              )
              .toList();
    }

    _allPokemons = filtered;
    if (_currentSortOrder == 'name') {
      _allPokemons.sort((a, b) => a.name.compareTo(b.name));
    } else {
      _allPokemons.sort((a, b) => a.id.compareTo(b.id));
    }

    loadNextPage();
  }
}
