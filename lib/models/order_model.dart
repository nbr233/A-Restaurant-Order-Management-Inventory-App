import 'package:flutter/foundation.dart';

class OrderItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<dynamic, dynamic> map) {
    return OrderItem(
      menuItemId: map['menuItemId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] is int ? map['quantity'] : int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String id;
  final String tableId; // table reference
  final String tableNumber; // for quick display
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double vat;
  final double grandTotal;
  final String status; // 'Pending', 'Cooking', 'Ready', 'Completed', 'Cancelled'
  final int timestamp;
  final String? paymentMethod; // 'Cash', 'Card', 'bKash', 'Nagad'

  OrderModel({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.vat,
    required this.grandTotal,
    this.status = 'Pending',
    required this.timestamp,
    this.paymentMethod,
  });

  factory OrderModel.fromMap(String id, Map<dynamic, dynamic> map) {
    try {
      var itemsData = map['items'];
      List<OrderItem> parsedItems = [];
      if (itemsData != null) {
        if (itemsData is List) {
          parsedItems = itemsData.map((item) => OrderItem.fromMap(item as Map)).toList();
        } else if (itemsData is Map) {
          parsedItems = itemsData.values.map((item) => OrderItem.fromMap(item as Map)).toList();
        }
      }

      return OrderModel(
        id: id,
        tableId: map['tableId']?.toString() ?? '',
        tableNumber: map['tableNumber']?.toString() ?? '',
        items: parsedItems,
        subtotal: (map['subtotal'] ?? 0).toDouble(),
        discount: (map['discount'] ?? 0).toDouble(),
        vat: (map['vat'] ?? 0).toDouble(),
        grandTotal: (map['grandTotal'] ?? 0).toDouble(),
        status: map['status']?.toString() ?? 'Pending',
        timestamp: map['timestamp'] is int ? map['timestamp'] : int.tryParse(map['timestamp']?.toString() ?? '0') ?? DateTime.now().millisecondsSinceEpoch,
        paymentMethod: map['paymentMethod']?.toString(),
      );
    } catch (e) {
      debugPrint('Error parsing OrderModel $id: $e');
      return OrderModel(
        id: id,
        tableId: '',
        tableNumber: '',
        items: [],
        subtotal: 0,
        discount: 0,
        vat: 0,
        grandTotal: 0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'tableId': tableId,
      'tableNumber': tableNumber,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'vat': vat,
      'grandTotal': grandTotal,
      'status': status,
      'timestamp': timestamp,
      'paymentMethod': paymentMethod,
    };
  }
}
