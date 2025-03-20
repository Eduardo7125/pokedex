import 'dart:convert';
import 'package:hive/hive.dart';

part 'Pokemon.g.dart';

@HiveType(typeId: 0)
class Pokemon extends HiveObject {
  static const String defaultImage =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/0.png';

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String animatedUrl;

  @HiveField(4)
  final List<String> types;

  @HiveField(5)
  bool isFavorite;

  @HiveField(6)
  final int height;

  @HiveField(7)
  final int weight;

  @HiveField(8)
  final Map<String, int> stats;

  @HiveField(9)
  final String cryUrl;

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
    this.cryUrl = '',
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'];
    final showdown = sprites['other']?['showdown'];
    final artwork = sprites['other']?['official-artwork'];
    final cries = json['cries'];

    return Pokemon(
      id: json['id'],
      name: json['name'],
      types:
          (json['types'] as List)
              .map((type) => type['type']['name'] as String)
              .toList(),
      imageUrl:
          artwork?['front_default'] ?? sprites['front_default'] ?? defaultImage,
      animatedUrl:
          showdown?['front_default'] ??
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
      cryUrl: cries?['latest'] ?? '',
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
      'cryUrl': cryUrl,
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
      cryUrl: map['cryUrl'] ?? '',
    );
  }

  String get detailImageUrl {
    return imageUrl;
  }
}
