import 'package:hive/hive.dart';

part 'restaurant_model.g.dart';

@HiveType(typeId: 1)
class RestaurantModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String cuisine;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final double rating;

  @HiveField(5)
  final int deliveryTime; // in minutes

  @HiveField(6)
  final bool isFavorite;

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final List<String> tags;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.imageUrl,
    required this.rating,
    required this.deliveryTime,
    this.isFavorite = false,
    this.description,
    this.tags = const [],
  });

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? cuisine,
    String? imageUrl,
    double? rating,
    int? deliveryTime,
    bool? isFavorite,
    String? description,
    List<String>? tags,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisine: cuisine ?? this.cuisine,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'imageUrl': imageUrl,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'isFavorite': isFavorite,
      'description': description,
      'tags': tags,
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cuisine: map['cuisine'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      deliveryTime: map['deliveryTime'] ?? 0,
      isFavorite: map['isFavorite'] ?? false,
      description: map['description'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
