import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Fruit {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String name;

  Fruit({required this.id, required this.name});
}
