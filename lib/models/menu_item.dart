import 'package:flutter/foundation.dart';

class RecipeIngredient {
  final String ingredientId;
  final String name;
  final double quantity;
  final String unit;

  RecipeIngredient({
    required this.ingredientId,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredient.fromMap(Map<dynamic, dynamic> map) {
    return RecipeIngredient(
      ingredientId: map['ingredientId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit']?.toString() ?? 'kg',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientId': ingredientId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class MenuItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final List<RecipeIngredient> recipe;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.recipe = const [],
  });

  factory MenuItem.fromMap(String id, Map<dynamic, dynamic> map) {
    try {
      var recipeList = <RecipeIngredient>[];
      if (map['recipe'] != null) {
        if (map['recipe'] is List) {
          recipeList = (map['recipe'] as List).map((i) => RecipeIngredient.fromMap(i as Map)).toList();
        } else if (map['recipe'] is Map) {
          recipeList = (map['recipe'] as Map).values.map((i) => RecipeIngredient.fromMap(i as Map)).toList();
        }
      }

      return MenuItem(
        id: id,
        name: map['name']?.toString() ?? '',
        category: map['category']?.toString() ?? '',
        price: (map['price'] ?? 0).toDouble(),
        imageUrl: map['imageUrl']?.toString(),
        isAvailable: map['isAvailable'] == true || map['isAvailable'] == 'true',
        recipe: recipeList,
      );
    } catch (e) {
      debugPrint('Error parsing MenuItem $id: $e');
      return MenuItem(id: id, name: 'Error Loading', category: '', price: 0);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'recipe': recipe.map((i) => i.toMap()).toList(),
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    List<RecipeIngredient>? recipe,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      recipe: recipe ?? this.recipe,
    );
  }
}
