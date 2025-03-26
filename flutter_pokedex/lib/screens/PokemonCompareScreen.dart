import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/providers/pokemon_provider.dart';
import 'package:flutter_pokedex/widgets/PokemonLoadingIndicator.dart';
import 'package:flutter_pokedex/widgets/PokemonSelectCard.dart';
import 'package:flutter_pokedex/widgets/PokemonWidget.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonCompareScreen extends StatefulWidget {
  const PokemonCompareScreen({Key? key}) : super(key: key);

  @override
  State<PokemonCompareScreen> createState() => _PokemonCompareScreenState();
}

class _PokemonCompareScreenState extends State<PokemonCompareScreen> {
  Pokemon? topPokemon;
  Pokemon? bottomPokemon;
  bool isComparing = false;

  void _showPokemonSelection(bool isTop) async {
    final Pokemon? selected = await showModalBottomSheet<Pokemon>(
      context: context,
      builder: (context) => _PokemonSelectionSheet(),
    );

    if (selected != null) {
      setState(() {
        if (isTop) {
          topPokemon = selected;
        } else {
          bottomPokemon = selected;
        }
      });
    }
  }

  Color _getStatDifferenceColor(int value1, int value2) {
    if (value1 > value2) return Colors.green;
    if (value1 < value2) return Colors.red;
    return Colors.grey;
  }

  Widget _buildStatComparison(String statName, int value1, int value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value1.toString(),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: _getStatDifferenceColor(value1, value2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              statName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value2.toString(),
              style: TextStyle(
                color: _getStatDifferenceColor(value2, value1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonSlot(Pokemon? pokemon, bool isTop) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child:
            pokemon != null
                ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors:
                          pokemon.types.length > 1
                              ? [
                                _getTypeColor(pokemon.types[0]),
                                _getTypeColor(pokemon.types[1]),
                              ]
                              : [
                                _getTypeColor(pokemon.types[0]),
                                _getTypeColor(
                                  pokemon.types[0],
                                ).withOpacity(0.7),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Hero(
                    tag:
                        'compare-pokemon-${pokemon.id}-${isTop ? "top" : "bottom"}',
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      height: 150,
                      width: 150,
                      placeholder:
                          (context, url) => const SizedBox(
                            height: 150,
                            width: 150,
                            child: Center(child: PokemonLoadingIndicator()),
                          ),
                      errorWidget:
                          (context, url, error) => Image.network(
                            Pokemon.defaultImage,
                            height: 150,
                            width: 150,
                          ),
                    ),
                  ),
                )
                : const Icon(Icons.add_circle_outline, size: 48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCompare = topPokemon != null && bottomPokemon != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comparador',
          style: GoogleFonts.pressStart2p(fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showPokemonSelection(true),
              child: _buildPokemonSlot(topPokemon, true),
            ),
          ),
          if (isComparing)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatComparison(
                      'HP',
                      topPokemon!.stats['hp']!,
                      bottomPokemon!.stats['hp']!,
                    ),
                    _buildStatComparison(
                      'Ataque',
                      topPokemon!.stats['attack']!,
                      bottomPokemon!.stats['attack']!,
                    ),
                    _buildStatComparison(
                      'Defensa',
                      topPokemon!.stats['defense']!,
                      bottomPokemon!.stats['defense']!,
                    ),
                    _buildStatComparison(
                      'Atq. Esp.',
                      topPokemon!.stats['special-attack']!,
                      bottomPokemon!.stats['special-attack']!,
                    ),
                    _buildStatComparison(
                      'Def. Esp.',
                      topPokemon!.stats['special-defense']!,
                      bottomPokemon!.stats['special-defense']!,
                    ),
                    _buildStatComparison(
                      'Velocidad',
                      topPokemon!.stats['speed']!,
                      bottomPokemon!.stats['speed']!,
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showPokemonSelection(false),
              child: _buildPokemonSlot(bottomPokemon, false),
            ),
          ),
        ],
      ),
      floatingActionButton:
          canCompare
              ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    isComparing = !isComparing;
                  });
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.red.shade700, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Icon(
                    isComparing ? Icons.close : Icons.compare_arrows,
                    color: Colors.white,
                  ),
                ),
              )
              : null,
    );
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
      return Colors.orange;
    case 'rock':
      return Colors.brown;
    case 'ground':
      return Colors.brown.shade200;
    case 'flying':
      return Colors.indigo;
    case 'bug':
      return Colors.lightGreen;
    case 'poison':
      return Colors.purple;
    case 'ghost':
      return Colors.deepPurple;
    case 'dragon':
      return Colors.indigo;
    case 'dark':
      return Colors.grey.shade800;
    case 'steel':
      return Colors.blueGrey;
    case 'fairy':
      return Colors.pink;
    default:
      return Colors.grey;
  }
}

class _PokemonSelectionSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PokemonProvider>(
      builder: (context, provider, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Seleccionar Pokémon',
                style: GoogleFonts.pressStart2p(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: provider.allPokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = provider.allPokemons[index];
                    return PokemonSelectCard(
                      pokemon: pokemon,
                      onSelect: () => Navigator.pop(context, pokemon),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
