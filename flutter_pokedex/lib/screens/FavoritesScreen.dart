import 'package:flutter/material.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:flutter_pokedex/core/hive_helper.dart';
import 'package:flutter_pokedex/widgets/PokemonWidget.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Pokemon> favorites = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final favs = await HiveHelper.getFavorites();
      setState(() {
        favorites = favs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading favorites: $e')));
      }
    }
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    return PokemonCard(
      pokemon: pokemon,
      onFavoriteChanged: () async {
        await _loadFavorites();
      },
      isListView: false, // Add this parameter
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favoritos',
          style: GoogleFonts.pressStart2p(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : favorites.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes favoritos',
                      style: GoogleFonts.pressStart2p(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: favorites.length,
                itemBuilder:
                    (context, index) => PokemonCard(
                      key: ValueKey('favorite-${favorites[index].id}'),
                      pokemon: favorites[index],
                      onFavoriteChanged: _loadFavorites,
                      useHero: true,
                      isListView: false, // Add this parameter
                    ),
              ),
    );
  }
}
