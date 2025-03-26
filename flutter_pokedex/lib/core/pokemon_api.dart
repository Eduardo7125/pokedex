import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:http/http.dart' as http;

Future<Pokemon> _fetchPokemonDetails(Map<String, dynamic> args) async {
  final String url = args['url'];
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return Pokemon.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load pokemon details');
  }
}

class PokemonApi {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<Pokemon> fetchPokemonDetails(String pokemon) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon/${pokemon.toLowerCase()}'),
    );

    if (response.statusCode == 200) {
      final pokemonDetail = await compute(jsonDecode, response.body);
      return Pokemon.fromJson(pokemonDetail);
    } else {
      throw Exception('Pokémon not found');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllPokemonBasic() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon?limit=1302'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      List<Future<Map<String, dynamic>>> requests =
          results.map<Future<Map<String, dynamic>>>((result) async {
        final detailResponse = await http.get(Uri.parse(result['url']));

        if (detailResponse.statusCode == 200) {
          final detailData = json.decode(detailResponse.body);
          return {
            'name': result['name'],
            'id': detailData['id'],
            'url': result['url'],
            'types': detailData['types']
                .map((typeInfo) => typeInfo['type']['name'])
                .toList(),
            'image': detailData['sprites']['other']?['official-artwork']
                    ?['front_default'] ??
                detailData['sprites']['front_default'],
          };
        } else {
          throw Exception(
            'Failed to load Pokémon details for ${result['name']}',
          );
        }
      }).toList();

      return await Future.wait(requests);
    } else {
      throw Exception('Failed to load Pokémon list');
    }
  }

  Future<Pokemon> getRandomPokemon() async {
    try {
      final random = Random();
      final randomId = random.nextInt(1008) + 1;
      return await fetchPokemonDetails(randomId.toString());
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
