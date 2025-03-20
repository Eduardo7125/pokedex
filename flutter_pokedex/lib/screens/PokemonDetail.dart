import 'package:flutter/material.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/core/hive_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonDetail extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetail({super.key, required this.pokemon});

  @override
  State<PokemonDetail> createState() => _PokemonDetailState();
}

class _PokemonDetailState extends State<PokemonDetail> {
  Future<void> _toggleFavorite() async {
    try {
      await HiveHelper.toggleFavorite(widget.pokemon);
      setState(() {
        widget.pokemon.isFavorite = !widget.pokemon.isFavorite;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar favorito: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemon.name),
        actions: [
          IconButton(
            icon: Icon(
              widget.pokemon.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.pokemon.isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Hero(
                tag: 'pokemon-${widget.pokemon.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.pokemon.detailImageUrl,
                  height: 200,
                  width: 200,
                  placeholder: (context, url) => const SizedBox(
                    height: 200,
                    width: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.network(
                    Pokemon.defaultImage,
                    height: 200,
                    width: 200,
                  ),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: widget.pokemon.types.map((type) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Características',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Altura', '${widget.pokemon.height / 10}m'),
                    _buildInfoRow('Peso', '${widget.pokemon.weight / 10}kg'),
                    const SizedBox(height: 16),
                    Text(
                      'Estadísticas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...widget.pokemon.stats.entries.map((stat) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(stat.key.toUpperCase()),
                              Text(stat.value.toString()),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: stat.value / 255,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatColor(stat.key),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
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
        return Colors.brown[300]!;
      case 'flying':
        return Colors.indigo;
      case 'bug':
        return Colors.lightGreen;
      case 'poison':
        return Colors.deepPurple;
      case 'ghost':
        return Colors.deepPurple[300]!;
      case 'dragon':
        return Colors.indigo[400]!;
      case 'dark':
        return Colors.grey[800]!;
      case 'steel':
        return Colors.grey[400]!;
      case 'fairy':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Color _getStatColor(String stat) {
    switch (stat.toLowerCase()) {
      case 'hp':
        return Colors.red;
      case 'attack':
        return Colors.orange;
      case 'defense':
        return Colors.blue;
      case 'special-attack':
        return Colors.purple;
      case 'special-defense':
        return Colors.green;
      case 'speed':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
