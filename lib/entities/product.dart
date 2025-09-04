import 'package:flutter_ecommerce/entities/rating.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String category;
  final Rating rating;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] as String? ?? '',
      category: json['category'] as String? ?? '',
      rating: Rating.fromJson(json['rating'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title};
  }
}
