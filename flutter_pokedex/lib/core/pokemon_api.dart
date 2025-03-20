import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:http/http.dart' as http;

// Data structure for passing arguments to isolate
class FetchArguments {
  final String url;
  final int limit;
  FetchArguments(this.url, this.limit);
}

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
  static const int limit = 1500; // First generation only

  Future<List<Pokemon>> getPokemons() async {
    try {
      final listResponse = await http.get(
        Uri.parse('$baseUrl/pokemon?limit=$limit'),
      );

      if (listResponse.statusCode != 200) {
        throw Exception('Failed to load pokemon list');
      }

      final listData = json.decode(listResponse.body);
      final List<dynamic> results = listData['results'];

      final responses = await Future.wait(
        results.map((pokemon) => http.get(Uri.parse(pokemon['url']))),
      );

      return responses
          .where((response) => response.statusCode == 200)
          .map((response) => Pokemon.fromJson(json.decode(response.body)))
          .toList();
    } catch (e) {
      throw Exception('Error fetching pokemon data: $e');
    }
  }

  Future<Pokemon> getPokemonDetails(String name) async {
    try {
      final url = '$baseUrl/pokemon/$name';
      return await compute(_fetchPokemonDetails, {'url': url});
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Pokemon> getRandomPokemon() async {
    try {
      final random = Random();
      final randomId = random.nextInt(limit) + 1;
      final url = '$baseUrl/pokemon/$randomId';

      return await compute(_fetchPokemonDetails, {'url': url});
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
