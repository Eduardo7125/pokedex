// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Pokemon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PokemonAdapter extends TypeAdapter<Pokemon> {
  @override
  final int typeId = 0;

  @override
  Pokemon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pokemon(
      id: fields[0] as int,
      name: fields[1] as String,
      types: (fields[4] as List).cast<String>(),
      imageUrl: fields[2] as String,
      animatedUrl: fields[3] as String,
      height: fields[6] as int,
      weight: fields[7] as int,
      stats: (fields[8] as Map).cast<String, int>(),
      isFavorite: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Pokemon obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.animatedUrl)
      ..writeByte(4)
      ..write(obj.types)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.height)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
