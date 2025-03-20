import 'package:flutter/material.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/core/hive_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_pokedex/providers/pokemon_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class PokemonDetail extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetail({super.key, required this.pokemon});

  @override
  State<PokemonDetail> createState() => _PokemonDetailState();
}

class _PokemonDetailState extends State<PokemonDetail> {
  bool _isShowingGif = false;
  Timer? _gifTimer;
  late Future<String?> _animatedImageFuture;
  bool _hasLoadedAnimated = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingCry = false;

  @override
  void initState() {
    super.initState();
    _animatedImageFuture = Future.value(null);
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final isFav = await HiveHelper.isFavorite(widget.pokemon);
      if (mounted) {
        setState(() {
          widget.pokemon.isFavorite = isFav;
        });
      }
    } catch (e) {
      debugPrint('Error loading favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      await context.read<PokemonProvider>().updatePokemonFavorite(
        widget.pokemon,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar favorito: $e')),
        );
      }
    }
  }

  void _handleCryButton() async {
    if (!_hasLoadedAnimated) {
      _animatedImageFuture = _loadAnimatedImage();
      _hasLoadedAnimated = true;
    }

    setState(() {
      _isShowingGif = true;
      _isPlayingCry = true;
    });

    // Play the cry sound
    if (widget.pokemon.cryUrl.isNotEmpty) {
      try {
        await _audioPlayer.play(UrlSource(widget.pokemon.cryUrl));
      } catch (e) {
        debugPrint('Error playing cry: $e');
      }
    }

    _gifTimer?.cancel();
    _gifTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isShowingGif = false;
          _isPlayingCry = false;
        });
      }
    });
  }

  Future<String?> _loadAnimatedImage() async {
    try {
      final response = await http.get(Uri.parse(widget.pokemon.detailImageUrl));
      if (response.statusCode == 200) {
        return widget.pokemon.detailImageUrl;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainType = widget.pokemon.types.first;
    final typeColor = _getTypeColor(mainType);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pokemon.name,
          style: GoogleFonts.pressStart2p(fontSize: 16),
        ),
        backgroundColor: typeColor.withOpacity(0.8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              widget.pokemon.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.pokemon.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      backgroundColor: typeColor.withOpacity(0.1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      widget.pokemon.types.length > 1
                          ? [
                            _getTypeColor(widget.pokemon.types[0]),
                            _getTypeColor(widget.pokemon.types[1]),
                          ]
                          : [
                            _getTypeColor(widget.pokemon.types[0]),
                            _getTypeColor(
                              widget.pokemon.types[0],
                            ).withOpacity(0.7),
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Hero(
                        tag: 'pokemon-${widget.pokemon.id}',
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: CachedNetworkImage(
                              imageUrl:
                                  _isShowingGif
                                      ? widget.pokemon.detailImageUrl
                                      : widget.pokemon.imageUrl,
                              height: 200,
                              width: 200,
                              placeholder:
                                  (context, url) => const SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Image.network(
                                    Pokemon.defaultImage,
                                    height: 200,
                                    width: 200,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: FloatingActionButton.small(
                          onPressed: _handleCryButton,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Icon(
                            _isPlayingCry ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '#${widget.pokemon.id.toString().padLeft(3, '0')}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
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
                      children:
                          widget.pokemon.types.map((type) {
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
        children: [Text(label), Text(value)],
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
