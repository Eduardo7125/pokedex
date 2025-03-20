import 'package:flutter/material.dart';

class PokemonLoadingIndicator extends StatelessWidget {
  const PokemonLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/loading_pokemon.gif', height: 100, width: 100);
  }
}
