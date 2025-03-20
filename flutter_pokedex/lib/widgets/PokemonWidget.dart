import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/core/database_helper.dart';
import 'package:flutter_pokedex/screens/PokemonDetail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class PokemonCard extends StatefulWidget {
  final Pokemon pokemon;
  final VoidCallback? onFavoriteChanged;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onFavoriteChanged,
  });

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  bool _isShowingGif = false;
  Timer? _gifTimer;
  late Future<String?> _animatedImageFuture;
  bool _hasLoadedAnimated = false;

  @override
  void initState() {
    super.initState();
    _animatedImageFuture = Future.value(null);
  }

  void _handleDoubleTap() {
    if (!_hasLoadedAnimated) {
      // Load animated image only when needed
      _animatedImageFuture = _loadAnimatedImage();
      _hasLoadedAnimated = true;
    }

    setState(() {
      _isShowingGif = true;
    });

    _gifTimer?.cancel();
    _gifTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isShowingGif = false;
        });
      }
    });
  }

  Future<String?> _loadAnimatedImage() async {
    try {
      final url = widget.pokemon.animatedUrl;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return url;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  final dbHelper = DatabaseHelper.instance;

  Future<void> _toggleFavorite() async {
    await dbHelper.toggleFavorite(widget.pokemon);
    setState(() {
      widget.pokemon.isFavorite = !widget.pokemon.isFavorite;
    });
    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: isDark ? Colors.grey[850] : Colors.white,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetail(pokemon: widget.pokemon),
                ),
              );
            },
            onDoubleTap: _handleDoubleTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'pokemon-${widget.pokemon.id}',
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isShowingGif
                        ? FutureBuilder<String?>(
                            future: _animatedImageFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.network(
                                  snapshot.data!,
                                  height: 140,
                                  width: 140,
                                  key: const ValueKey('gif'),
                                );
                              }
                              return CachedNetworkImage(
                                imageUrl: widget.pokemon.thumbnailUrl,
                                height: 140,
                                width: 140,
                                placeholder: (context, url) => const SizedBox(
                                  height: 140,
                                  width: 140,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.network(
                                  Pokemon.defaultImage,
                                  height: 140,
                                  width: 140,
                                ),
                              );
                            },
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.pokemon.thumbnailUrl,
                            height: 140,
                            width: 140,
                            placeholder: (context, url) => const SizedBox(
                              height: 140,
                              width: 140,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.network(
                              Pokemon.defaultImage,
                              height: 140,
                              width: 140,
                            ),
                            key: const ValueKey('static'),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.pokemon.name,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.pokemon.types.map((type) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              widget.pokemon.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.pokemon.isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleFavorite,
          ),
        ),
      ],
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
}
