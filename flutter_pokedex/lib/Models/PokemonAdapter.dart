import 'package:hive/hive.dart';
import 'Pokemon.dart';

class PokemonAdapter extends TypeAdapter<Pokemon> {
  @override
  final int typeId = 0;

  @override
  Pokemon read(BinaryReader reader) {
    return Pokemon(
      id: reader.readInt(),
      name: reader.readString(),
      imageUrl: reader.readString(),
      animatedUrl: reader.readString(),
      types: List<String>.from(reader.readList()),
      height: reader.readInt(),
      weight: reader.readInt(),
      stats: Map<String, int>.from(reader.readMap()),
      isFavorite: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Pokemon obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.imageUrl);
    writer.writeString(obj.animatedUrl);
    writer.writeList(obj.types);
    writer.writeInt(obj.height);
    writer.writeInt(obj.weight);
    writer.writeMap(obj.stats);
    writer.writeBool(obj.isFavorite);
  }
}
