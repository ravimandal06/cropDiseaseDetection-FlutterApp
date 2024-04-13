import 'package:crop_disease_detection/hiveClass.dart';
import 'package:hive/hive.dart';

class FruitAdapter extends TypeAdapter<Fruit> {
  @override
  final int typeId = 1; // Unique identifier for the adapter

  @override
  Fruit read(BinaryReader reader) {
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldsCount; i++) reader.readByte(): reader.read(),
    };
    return Fruit(
      id: fields[0] as int,
      name: fields[1] as String,
      // Add more fields if needed
    );
  }

  @override
  void write(BinaryWriter writer, Fruit obj) {
    writer
      ..writeByte(2) // Number of fields in the object
      ..writeByte(0) // Field index 0
      ..write(obj.id) // Write id
      ..writeByte(1) // Field index 1
      ..write(obj.name); // Write name
    // Add more fields if needed
  }
}

class MyCustomTypeAdapter extends TypeAdapter<Fruit> {
  @override
  final int typeId = 32; // Unique identifier for the adapter

  @override
  Fruit read(BinaryReader reader) {
    // Read data from binary and construct a Fruit object
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldsCount; i++) reader.readByte(): reader.read(),
    };
    return Fruit(
      // Construct Fruit object using data read from binary
      // Example:
      id: fields[0] as int,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Fruit obj) {
    // Write MyCustomType object to binary
    writer
      ..writeByte(2) // Number of fields in the object
      ..writeByte(0) // Field index 0
      ..write(obj.id) // Write id
      ..writeByte(1) // Field index 1
      ..write(obj.name); // Write name
  }
}
