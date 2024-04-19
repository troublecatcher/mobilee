import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String description;
  final num price;
  final List<String> images;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.images,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      name: data['product-name'] as String,
      description: data['product-description'] as String,
      price: data['product-price'] as num,
      images: List<String>.from(data['product-img'] as List<dynamic>),
    );
  }
}
