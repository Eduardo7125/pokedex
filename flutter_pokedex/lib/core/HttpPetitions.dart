import 'dart:convert';

import 'package:flutter_pokedex/Models/Pokemon.dart';
import 'package:http/http.dart' as http;

Future<List<Pokemon>> fetchPokemons({required int offset}) async {
  final response = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20&offset=$offset'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<Future<Pokemon>> pokemons =
        (data['results'] as List).map((pokemonData) async {
      final pokemonResponse = await fetchPokemonbyName(pokemonData['name']);
      return Pokemon.fromJson(jsonDecode(pokemonResponse.body));
    }).toList();

    return Future.wait(pokemons);
  } else {
    throw Exception('Failed to load Pokémon');
  }
}

Future<http.Response> fetchPokemonbyName(String name) {
  return http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon-form/$name'),
  );
}

Future<List<Pokemon>> searchPokemons(String query) async {
  final response = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=2000'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<Future<Pokemon>> pokemons =
        (data['results'] as List).where((pokemonData) {
      return pokemonData['name'].toLowerCase().contains(query.toLowerCase());
    }).map((pokemonData) async {
      final pokemonResponse = await fetchPokemonbyName(pokemonData['name']);
      return Pokemon.fromJson(jsonDecode(pokemonResponse.body));
    }).toList();

    return Future.wait(pokemons);
  } else {
    throw Exception('Failed to search Pokémon');
  }
}
