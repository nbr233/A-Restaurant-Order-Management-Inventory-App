import 'package:flutter/foundation.dart';

class InventoryItem {
  final String id;
  final String name;
  final double stock;
  final String unit; // 'kg', 'liter', 'pcs'

  InventoryItem({
    required this.id,
    required this.name,
    required this.stock,
    required this.unit,
  });

  String get status {
    if (stock <= 0) return 'Out of Stock';
    if (stock < 5) return 'Low Stock'; // arbitrary low stock threshold
    return 'In Stock';
  }

  factory InventoryItem.fromMap(String id, Map<dynamic, dynamic> map) {
    try {
      return InventoryItem(
        id: id,
        name: map['name']?.toString() ?? '',
        stock: (map['stock'] ?? 0).toDouble(),
        unit: map['unit']?.toString() ?? '',
      );
    } catch (e) {
      debugPrint('Error parsing InventoryItem $id: $e');
      return InventoryItem(id: id, name: 'Error', stock: 0, unit: '');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stock': stock,
      'unit': unit,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    double? stock,
    String? unit,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
    );
  }
}
