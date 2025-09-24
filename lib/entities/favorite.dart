import 'package:flutter_ecommerce/entities/product.dart';

class Favorite {
  final int? id;
  final int productId;
  final Product? product;
  final DateTime addedAt;

  const Favorite({
    this.id,
    required this.productId,
    this.product,
    required this.addedAt,
  });

  factory Favorite.fromMap(Map<String, dynamic> map, {Product? product}) {
    return Favorite(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      product: product,
      addedAt: DateTime.parse(map['added_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'added_at': addedAt.toIso8601String(),
    };
  }

  Favorite copyWith({
    int? id,
    int? productId,
    Product? product,
    DateTime? addedAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favorite && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;

  @override
  String toString() {
    return 'Favorite(id: $id, productId: $productId, addedAt: $addedAt)';
  }
}
