import 'package:hive/hive.dart';

part 'promotional_banner_model.g.dart';

@HiveType(typeId: 2)
class PromotionalBannerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final String? discountText;

  @HiveField(6)
  final String? buttonText;

  @HiveField(7)
  final String? phoneNumber;

  @HiveField(8)
  final String? website;

  PromotionalBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    this.discountText,
    this.buttonText,
    this.phoneNumber,
    this.website,
  });

  PromotionalBannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? discountText,
    String? buttonText,
    String? phoneNumber,
    String? website,
  }) {
    return PromotionalBannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      discountText: discountText ?? this.discountText,
      buttonText: buttonText ?? this.buttonText,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'imageUrl': imageUrl,
      'discountText': discountText,
      'buttonText': buttonText,
      'phoneNumber': phoneNumber,
      'website': website,
    };
  }

  factory PromotionalBannerModel.fromMap(Map<String, dynamic> map) {
    return PromotionalBannerModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      discountText: map['discountText'],
      buttonText: map['buttonText'],
      phoneNumber: map['phoneNumber'],
      website: map['website'],
    );
  }
}
