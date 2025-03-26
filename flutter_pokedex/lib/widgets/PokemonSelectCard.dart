import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/widgets/PokemonLoadingIndicator.dart';

class PokemonSelectCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onSelect;

  const PokemonSelectCard({
    Key? key,
    required this.pokemon,
    required this.onSelect,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final mainType = pokemon.types.first;
    final typeColor = _getTypeColor(mainType);

    return InkWell(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.all(4),
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
                      _getTypeColor(pokemon.types[0]).withOpacity(0.7),
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pokeball background
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
              margin: const EdgeInsets.all(8),
            ),
            // Pokemon image
            Hero(
              tag: 'select-pokemon-${pokemon.id}',
              child: CachedNetworkImage(
                imageUrl: pokemon.imageUrl,
                height: 80,
                width: 80,
                placeholder:
                    (context, url) => const SizedBox(
                      height: 80,
                      width: 80,
                      child: Center(child: PokemonLoadingIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Image.network(
                      Pokemon.defaultImage,
                      height: 80,
                      width: 80,
                    ),
              ),
            ),
            // Pokemon number
            Positioned(
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
