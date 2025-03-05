import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';

class PokemonWidget extends StatefulWidget {
  final Pokemon pokemon;
  const PokemonWidget({super.key, required this.pokemon});

  @override
  State<PokemonWidget> createState() => _PokemonWidgetState();
}

class _PokemonWidgetState extends State<PokemonWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: widget.pokemon.front_img,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pokemon.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 10),
                // Text(
                //   'Type: ${widget.pokemon.type}',
                //   style: TextStyle(
                //     fontSize: 18,
                //     color: Colors.blueAccent,
                //   ),
                // ),
                // SizedBox(height: 10),
                // Row(
                //   children: [
                //     Icon(Icons.star, color: Colors.yellow, size: 20),
                //     SizedBox(width: 5),
                //     Text(
                //       'Level: ${widget.pokemon.level}',
                //       style: TextStyle(
                //         fontSize: 16,
                //         color: Colors.grey[600],
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
