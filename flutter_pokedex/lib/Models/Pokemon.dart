import 'dart:convert';

class Pokemon {
  static const String defaultImage =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/0.png';

  final int id;
  final String name;
  final List<String> types;
  final String imageUrl;
  final String animatedUrl;
  final int height;
  final int weight;
  final Map<String, int> stats;
  bool isFavorite;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.imageUrl,
    required this.animatedUrl,
    required this.height,
    required this.weight,
    required this.stats,
    this.isFavorite = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'];
    final showdown = sprites['other']?['showdown'];
    final artwork = sprites['other']?['official-artwork'];

    return Pokemon(
      id: json['id'],
      name: json['name'],
      types: (json['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
      imageUrl:
          artwork?['front_default'] ?? sprites['front_default'] ?? defaultImage,
      animatedUrl: showdown?['front_default'] ??
          sprites['front_default'] ??
          defaultImage,
      height: json['height'],
      weight: json['weight'],
      stats: Map<String, int>.from({
        'hp': json['stats'][0]['base_stat'],
        'attack': json['stats'][1]['base_stat'],
        'defense': json['stats'][2]['base_stat'],
        'special-attack': json['stats'][3]['base_stat'],
        'special-defense': json['stats'][4]['base_stat'],
        'speed': json['stats'][5]['base_stat'],
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'types': types,
      'imageUrl': imageUrl,
      'animatedUrl': animatedUrl,
      'height': height,
      'weight': weight,
      'stats': stats,
      'isFavorite': isFavorite,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'],
      name: map['name'],
      types: List<String>.from(jsonDecode(map['types'])),
      imageUrl: map['imageUrl'] ?? defaultImage,
      animatedUrl: map['animatedUrl'] ?? defaultImage,
      height: map['height'],
      weight: map['weight'],
      stats: Map<String, int>.from(jsonDecode(map['stats'])),
      isFavorite: map['isFavorite'] == 1,
    );
  }

  String get thumbnailUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png';
  }

  String get detailImageUrl {
    return imageUrl;
  }
}
