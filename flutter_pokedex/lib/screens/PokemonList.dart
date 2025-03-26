import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pokedex/providers/pokemon_provider.dart';
import 'package:flutter_pokedex/screens/FavoritesScreen.dart';
import 'package:flutter_pokedex/screens/PokemonCompareScreen.dart';
import 'package:flutter_pokedex/widgets/PokemonErrorWidget.dart';
import 'package:flutter_pokedex/widgets/PokemonLoadingIndicator.dart';
import 'package:flutter_pokedex/widgets/PokemonWidget.dart';
import 'package:provider/provider.dart';
import 'PokemonDetail.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonList extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const PokemonList({super.key, required this.onThemeToggle});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  final ScrollController _scrollController = ScrollController();
  bool isGridView = false;
  String searchQuery = '';
  String selectedType = 'all';
  String sortBy = 'number';
  bool isFilterVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PokemonProvider>().loadPokemons();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PokemonProvider>().loadNextPage();
    }
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (isFilterVisible) {
        setState(() => isFilterVisible = false);
      }
    }
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!isFilterVisible) {
        setState(() => isFilterVisible = true);
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return Colors.purple;
      case 'fighting':
        return Colors.brown;
      case 'rock':
        return Colors.grey;
      case 'ground':
        return Colors.orange;
      case 'flying':
        return Colors.lightBlue;
      case 'bug':
        return Colors.lightGreen;
      case 'poison':
        return Colors.deepPurple;
      case 'ghost':
        return Colors.indigo;
      case 'dragon':
        return Colors.deepOrange;
      case 'dark':
        return Colors.black;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<PokemonProvider>().applyFilters(
      searchQuery: searchQuery,
      sortBy: sortBy,
    );
  }

  void _showTypeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Tipos'),
          content: SizedBox(
            width: double.maxFinite,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    'fire',
                    'water',
                    'grass',
                    'electric',
                    'psychic',
                    'fighting',
                    'rock',
                    'ground',
                    'flying',
                    'bug',
                    'poison',
                    'ghost',
                    'dragon',
                    'dark',
                    'steel',
                    'fairy',
                  ].map((type) {
                    final isSelected = context
                        .watch<PokemonProvider>()
                        .selectedTypes
                        .contains(type);
                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      label: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      backgroundColor: _getTypeColor(type).withOpacity(0.2),
                      selectedColor: _getTypeColor(type),
                      onSelected: (selected) {
                        context.read<PokemonProvider>().toggleType(type);
                      },
                    );
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
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
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PokemonCompareScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          // Filter section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isFilterVisible ? 82 : 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Left side - Type selection
                  Expanded(
                    child: InkWell(
                      onTap: _showTypeSelectionDialog,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.filter_list),
                                  const SizedBox(width: 8),
                                  Text(
                                    context
                                            .watch<PokemonProvider>()
                                            .selectedTypes
                                            .isEmpty
                                        ? 'Tipos'
                                        : '${context.watch<PokemonProvider>().selectedTypes.length} seleccionados',
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Vertical divider
                  Container(
                    width: 1,
                    height: 50,
                    color: Theme.of(context).dividerColor,
                  ),
                  // Right side - Sort selection
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: sortBy,
                          isExpanded: true,
                          icon: const Icon(Icons.sort),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: const [
                            DropdownMenuItem(
                              value: 'number',
                              child: Text('Index de Pokédex'),
                            ),
                            DropdownMenuItem(
                              value: 'name',
                              child: Text('Alfabéticamente'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              sortBy = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<PokemonProvider>(
              builder: (context, provider, child) {
                if (provider.error.isNotEmpty) {
                  return PokemonErrorWidget(
                    message: provider.error,
                    onRetry: () => provider.loadPokemons(refresh: true),
                  );
                }

                if (provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const PokemonLoadingIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando Pokédex... ${provider.loadingProgress}%',
                          style: GoogleFonts.pressStart2p(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (provider.displayedPokemons.isEmpty) {
                  return const Center(child: Text('No se encontraron Pokémon'));
                }

                return isGridView
                    ? GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                0.75, // Ajustado para mejor proporción
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: provider.displayedPokemons.length,
                      cacheExtent: 1000, // Increase cache extent
                      addAutomaticKeepAlives: true,
                      itemBuilder: (context, index) {
                        final pokemon = provider.displayedPokemons[index];
                        return PokemonCard(
                          key: ValueKey('pokemon-${pokemon.id}'),
                          pokemon: pokemon,
                          onFavoriteChanged: () => setState(() {}),
                          useHero: true,
                          isListView: !isGridView,
                        );
                      },
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: provider.displayedPokemons.length,
                      cacheExtent: 1000,
                      addAutomaticKeepAlives: true,
                      itemBuilder: (context, index) {
                        final pokemon = provider.displayedPokemons[index];
                        return PokemonCard(
                          key: ValueKey('pokemon-${pokemon.id}'),
                          pokemon: pokemon,
                          onFavoriteChanged: () => setState(() {}),
                          useHero: true,
                          isListView: !isGridView,
                        );
                      },
                    );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFilterVisible)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.small(
                onPressed: () => setState(() => isFilterVisible = true),
                child: const Icon(Icons.filter_list),
              ),
            ),
          FloatingActionButton(
            onPressed: () async {
              final pokemon =
                  context.read<PokemonProvider>().getRandomPokemon();
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
        ],
      ),
    );
  }
}
