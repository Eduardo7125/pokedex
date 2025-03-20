import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/core/hive_helper.dart';
import 'package:flutter_pokedex/screens/PokemonDetail.dart';
import 'package:flutter_pokedex/widgets/PokemonLoadingIndicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_pokedex/providers/pokemon_provider.dart';

class PokemonCard extends StatefulWidget {
  final Pokemon pokemon;
  final VoidCallback? onFavoriteChanged;

  const PokemonCard({super.key, required this.pokemon, this.onFavoriteChanged});

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  bool _isShowingGif = false;
  Timer? _gifTimer;
  late Future<String?> _animatedImageFuture;
  bool _hasLoadedAnimated = false;
  bool _isHovered = false;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animatedImageFuture = Future.value(null);
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
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

  Future<void> _toggleFavorite() async {
    try {
      await context.read<PokemonProvider>().updatePokemonFavorite(
        widget.pokemon,
      );

      if (widget.onFavoriteChanged != null) {
        widget.onFavoriteChanged!();
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainType =
        widget.pokemon.types.isNotEmpty ? widget.pokemon.types.first : 'normal';
    final typeColor = _getTypeColor(mainType);
    final backgroundColor = Color.lerp(
      typeColor,
      isDark ? Colors.black : Colors.white,
      0.85,
    );

    return Stack(
      children: [
        AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
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
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PokemonDetail(pokemon: widget.pokemon),
                      ),
                    );
                  },
                  onDoubleTap: _handleDoubleTap,
                  borderRadius: BorderRadius.circular(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Hero(
                          tag: 'pokemon-${widget.pokemon.id}',
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child:
                                _isShowingGif
                                    ? FutureBuilder<String?>(
                                      future: _animatedImageFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: typeColor.withOpacity(
                                                    0.2,
                                                  ),
                                                ),
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: snapshot.data!,
                                                  height: 120,
                                                  width: 120,
                                                  placeholder:
                                                      (
                                                        context,
                                                        url,
                                                      ) => const SizedBox(
                                                        height: 120,
                                                        width: 120,
                                                        child: Center(
                                                          child:
                                                              PokemonLoadingIndicator(),
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Image.network(
                                                            widget
                                                                .pokemon
                                                                .imageUrl,
                                                            height: 120,
                                                            width: 120,
                                                          ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        // Show static image while loading animated one
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: typeColor.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    widget.pokemon.imageUrl,
                                                height: 120,
                                                width: 120,
                                                placeholder:
                                                    (
                                                      context,
                                                      url,
                                                    ) => const SizedBox(
                                                      height: 120,
                                                      width: 120,
                                                      child: Center(
                                                        child:
                                                            PokemonLoadingIndicator(),
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.network(
                                                          Pokemon.defaultImage,
                                                          height: 120,
                                                          width: 120,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                    : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: typeColor.withOpacity(0.2),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.pokemon.imageUrl,
                                            height: 120,
                                            width: 120,
                                            placeholder:
                                                (
                                                  context,
                                                  url,
                                                ) => const SizedBox(
                                                  height: 120,
                                                  width: 120,
                                                  child: Center(
                                                    child:
                                                        PokemonLoadingIndicator(),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.network(
                                                      Pokemon.defaultImage,
                                                      height: 120,
                                                      width: 120,
                                                    ),
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '#${widget.pokemon.id.toString().padLeft(3, '0')}',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.pokemon.name,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            widget.pokemon.types.map((type) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(type),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getTypeColor(
                                        type,
                                      ).withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
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
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black54 : Colors.white70,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                widget.pokemon.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: widget.pokemon.isFavorite ? Colors.red : Colors.grey,
                size: 20,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetail(pokemon: widget.pokemon),
      ),
    );
  }

  Widget _buildPokemonImage(Color typeColor) {
    return Hero(
      tag: 'pokemon-${widget.pokemon.id}',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            _isShowingGif
                ? _buildAnimatedImage(typeColor)
                : _buildStaticImage(typeColor),
      ),
    );
  }

  Widget _buildAnimatedImage(Color typeColor) {
    return FutureBuilder<String?>(
      future: _animatedImageFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return _buildPokemonImageContainer(snapshot.data!, typeColor);
        }
        return _buildPokemonImageContainer(widget.pokemon.imageUrl, typeColor);
      },
    );
  }

  Widget _buildStaticImage(Color typeColor) {
    return _buildPokemonImageContainer(widget.pokemon.imageUrl, typeColor);
  }

  Widget _buildPokemonImageContainer(String imageUrl, Color typeColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: typeColor.withOpacity(0.2),
      ),
      padding: const EdgeInsets.all(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 120,
        width: 120,
        placeholder:
            (context, url) => const SizedBox(
              height: 120,
              width: 120,
              child: Center(child: PokemonLoadingIndicator()),
            ),
        errorWidget:
            (context, url, error) =>
                Image.network(Pokemon.defaultImage, height: 120, width: 120),
      ),
    );
  }

  Widget _buildPokemonId(Color typeColor) {
    return Text(
      '#${widget.pokemon.id.toString().padLeft(3, '0')}',
      style: GoogleFonts.pressStart2p(fontSize: 10, color: typeColor),
    );
  }

  Widget _buildPokemonName(bool isDark) {
    return Text(
      widget.pokemon.name,
      style: GoogleFonts.pressStart2p(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTypeChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          widget.pokemon.types.map((type) {
            final typeColor = _getTypeColor(type);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
    );
  }

  Widget _buildFavoriteButton(bool isDark) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black54 : Colors.white70,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            widget.pokemon.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.pokemon.isFavorite ? Colors.red : Colors.grey,
            size: 20,
          ),
          onPressed: _toggleFavorite,
        ),
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
}
