// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:http/http.dart' as http;

class Pokemon {
  String name;
  String front_img;
  String back_img;

  Pokemon(
      {required this.name, required this.front_img, required this.back_img});

  static Future<Pokemon> fromFutureJson(
      Future<http.Response> jsonResponse) async {
    final response = await jsonResponse;

    final data = jsonDecode(response.body);

    return Pokemon(
      name: data['name'] as String,
      front_img:
          data['sprites']['other']['showdown']['front_default'] as String,
      back_img: data['sprites']['back_default'] as String,
    );
  }

  static Pokemon fromJson(Map<String, dynamic> data) {
    return Pokemon(
      name: data['name'] as String,
      front_img: data['sprites']['front_default'] as String,
      back_img: data['sprites']['back_default'] as String,
    );
  }
}
