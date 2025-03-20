import 'package:flutter/material.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/providers/pokemon_provider.dart';
import 'package:flutter_pokedex/screens/FavoritesScreen.dart';
import 'package:flutter_pokedex/widgets/PokemonWidget.dart';
import 'package:provider/provider.dart';
import 'PokemonDetail.dart';

class PokemonList extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const PokemonList({
    super.key,
    required this.onThemeToggle,
  });

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  bool isGridView = false;
  String searchQuery = '';
  String selectedType = 'all';
  String sortBy = 'number';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokemonProvider>().loadPokemons();
    });
  }

  List<Pokemon> get filteredPokemons {
    final pokemons = context.watch<PokemonProvider>().pokemons;
    return pokemons.where((pokemon) {
      final matchesSearch =
          pokemon.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType =
          selectedType == 'all' || pokemon.types.contains(selectedType);
      return matchesSearch && matchesType;
    }).toList()
      ..sort((a, b) {
        if (sortBy == 'name') {
          return a.name.compareTo(b.name);
        }
        return a.id.compareTo(b.id);
      });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              widget.onThemeToggle();
            },
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar Pokémon...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar por tipo',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Text('Todos'),
                            ),
                            ...['fire', 'water', 'grass', 'electric', 'psychic']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          value: sortBy,
                          decoration: const InputDecoration(
                            labelText: 'Ordenar por',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'number',
                              child: Text('Número'),
                            ),
                            DropdownMenuItem(
                              value: 'name',
                              child: Text('Nombre'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              sortBy = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PokemonProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.pokemons.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.loadPokemons(refresh: true);
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredPokemons.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron Pokémon'),
                  );
                }

                return isGridView
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                        ),
                        itemCount: filteredPokemons.length,
                        itemBuilder: (context, index) {
                          return PokemonCard(pokemon: filteredPokemons[index]);
                        },
                      )
                    : ListView.builder(
                        itemCount: filteredPokemons.length,
                        itemBuilder: (context, index) {
                          return PokemonCard(pokemon: filteredPokemons[index]);
                        },
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final pokemon =
              await context.read<PokemonProvider>().getRandomPokemon();
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PokemonDetail(pokemon: pokemon),
              ),
            );
          }
        },
        child: const Icon(Icons.shuffle),
      ),
    );
  }
}
