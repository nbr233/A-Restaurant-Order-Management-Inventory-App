import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../models/table_model.dart';
import '../models/order_model.dart';
import '../models/inventory_item.dart';

class FirebaseService {
  DatabaseReference get _db => FirebaseDatabase.instance.ref();

  // Menu Items
  Stream<List<MenuItem>> getMenuItems() {
    return _db.child('menu').onValue.map((event) {
      try {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return [];
        
        final items = <MenuItem>[];
        data.forEach((key, value) {
          if (value is Map) {
            items.add(MenuItem.fromMap(key.toString(), Map<dynamic, dynamic>.from(value)));
          }
        });
        return items;
      } catch (e) {
        debugPrint('Firebase getMenuItems error: $e');
        return [];
      }
    });
  }

  Future<void> addMenuItem(MenuItem item) async {
    final newRef = _db.child('menu').push();
    await newRef.set(item.toMap());
  }

  Future<void> updateMenuItem(MenuItem item) async {
    await _db.child('menu').child(item.id).update(item.toMap());
  }

  Future<void> deleteMenuItem(String id) async {
    await _db.child('menu').child(id).remove();
  }

  // Tables
  Stream<List<TableModel>> getTables() {
    return _db.child('tables').onValue.map((event) {
      try {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return [];
        
        final items = <TableModel>[];
        data.forEach((key, value) {
          if (value is Map) {
            items.add(TableModel.fromMap(key.toString(), Map<dynamic, dynamic>.from(value)));
          }
        });
        return items..sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
      } catch (e) {
        debugPrint('Firebase getTables error: $e');
        return [];
      }
    });
  }

  Future<void> updateTableStatus(String tableId, String status) async {
    await _db.child('tables').child(tableId).update({'status': status});
  }

  Future<void> createTable(TableModel table) async {
    await _db.child('tables').child(table.id).set(table.toMap());
  }

  // Orders
  Stream<List<OrderModel>> getOrders() {
    return _db.child('orders').onValue.map((event) {
      try {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return [];
        
        final items = <OrderModel>[];
        data.forEach((key, value) {
          if (value is Map) {
            items.add(OrderModel.fromMap(key.toString(), Map<dynamic, dynamic>.from(value)));
          }
        });
        return items..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (e) {
        debugPrint('Firebase getOrders error: $e');
        return [];
      }
    });
  }

  Future<void> createOrder(OrderModel order) async {
    await _db.child('orders').child(order.id).set(order.toMap());
  }

  Future<void> updateOrder(OrderModel order) async {
    await _db.child('orders').child(order.id).set(order.toMap());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.child('orders').child(orderId).update({'status': status});
  }

  // Inventory
  Stream<List<InventoryItem>> getInventory() {
    return _db.child('inventory').onValue.map((event) {
      try {
        final data = event.snapshot.value;
        if (data == null) return [];
        
        final items = <InventoryItem>[];
        if (data is Map) {
          data.forEach((key, value) {
            if (value != null) {
              final Map<dynamic, dynamic> mapValue = value is Map ? value : {};
              items.add(InventoryItem.fromMap(key.toString(), mapValue));
            }
          });
        }
        return items;
      } catch (e) {
        debugPrint('Firebase getInventory error: $e');
        return [];
      }
    });
  }

  Future<void> addInventoryItem(InventoryItem item) async {
    final newRef = _db.child('inventory').push();
    await newRef.set(item.toMap());
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    await _db.child('inventory').child(item.id).update(item.toMap());
  }

  Future<void> deleteInventoryItem(String id) async {
    await _db.child('inventory').child(id).remove();
  }
}
