import 'package:flutter/material.dart';
import 'package:flutter_pokedex/core/HttpPetitions.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/widgets/PokemonWidget.dart';

class Pokemonlist extends StatefulWidget {
  const Pokemonlist({super.key});

  @override
  State<Pokemonlist> createState() => _PokemonlistState();
}

class _PokemonlistState extends State<Pokemonlist> {
  late Future<List<Pokemon>> list_pokemons;
  final List<Pokemon> _pokemons = [];
  final List<Pokemon> _filteredPokemons = [];
  int _offset = 0;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchPokemons() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final newPokemons = await fetchPokemons(offset: _offset);
    setState(() {
      _pokemons.addAll(newPokemons);
      _filteredPokemons.addAll(newPokemons);
      _offset += newPokemons.length;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredPokemons.clear();
        _filteredPokemons.addAll(_pokemons);
      });
    } else {
      _searchPokemons(query);
    }
  }

  Future<void> _searchPokemons(String query) async {
    setState(() {
      _isLoading = true;
    });
    final searchResults = await searchPokemons(query);
    setState(() {
      _filteredPokemons.clear();
      _filteredPokemons.addAll(searchResults);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        backgroundColor: Colors.red,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification.metrics.pixels ==
                    scrollNotification.metrics.maxScrollExtent &&
                !_isLoading) {
              _fetchPokemons();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _pokemons.clear();
                _filteredPokemons.clear();
                _offset = 0;
              });
              await _fetchPokemons();
            },
            child: ListView.builder(
              itemCount: _filteredPokemons.length,
              itemBuilder: (context, index) {
                return PokemonWidget(pokemon: _filteredPokemons[index]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
