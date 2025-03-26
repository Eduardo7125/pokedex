import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PokemonErrorWidget({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/sad_pikachu.png', height: 150),
          const SizedBox(height: 16),
          Text(
            '¡Algo ha ocurrido!',
            style: GoogleFonts.pressStart2p(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.pressStart2p(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(
              'Reintentar',
              style: GoogleFonts.pressStart2p(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
