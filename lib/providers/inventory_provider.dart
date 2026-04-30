import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/firebase_service.dart';

import '../config.dart';

class InventoryProvider extends ChangeNotifier {
  late final FirebaseService _firebaseService;
  
  List<InventoryItem> _inventory = [];
  bool _isLoading = true;

  List<InventoryItem> get inventory => _inventory;
  bool get isLoading => _isLoading;

  int get lowStockCount => _inventory.where((i) => i.status == 'Low Stock').length;
  int get outOfStockCount => _inventory.where((i) => i.status == 'Out of Stock').length;

  InventoryProvider() {
    if (!AppConfig.useMockData) {
      _firebaseService = FirebaseService();
    }
    _initInventoryStream();
  }

  void _initInventoryStream() {
    if (AppConfig.useMockData) {
      _inventory = [
        InventoryItem(id: 'i1', name: 'Tomatoes', stock: 10, unit: 'kg'),
        InventoryItem(id: 'i2', name: 'Cheese', stock: 20, unit: 'kg'),
        InventoryItem(id: 'i3', name: 'Bun', stock: 20, unit: 'pcs'),
        InventoryItem(id: 'i4', name: 'Chicken', stock: 10, unit: 'kg'),
      ];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _firebaseService.getInventory().listen((items) {
      _inventory = items;
      _isLoading = false;
      notifyListeners();
    });
  }

  // CRUD Methods
  Future<void> addInventoryItem(InventoryItem item) async {
    if (AppConfig.useMockData) {
      _inventory.add(item.id.isEmpty ? item.copyWith(id: 'inv_${DateTime.now().millisecondsSinceEpoch}') : item);
      notifyListeners();
      return;
    }
    await _firebaseService.addInventoryItem(item);
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    // Prevent stock from going negative
    final safeItem = item.stock < 0 ? item.copyWith(stock: 0) : item;

    if (AppConfig.useMockData) {
      final index = _inventory.indexWhere((i) => i.id == safeItem.id || i.name.toLowerCase() == safeItem.name.toLowerCase());
      if (index != -1) {
        _inventory[index] = safeItem;
        notifyListeners();
      }
      return;
    }
    await _firebaseService.updateInventoryItem(safeItem);
  }

  /// Converts a recipe quantity+unit into the inventory item's unit for comparison/deduction.
  double convertToInventoryUnit(double qty, String fromUnit, String toUnit) {
    if (fromUnit.toLowerCase() == toUnit.toLowerCase()) return qty;
    if (fromUnit.toLowerCase() == 'gm' && toUnit.toLowerCase() == 'kg') return qty / 1000;
    if (fromUnit.toLowerCase() == 'kg' && toUnit.toLowerCase() == 'gm') return qty * 1000;
    if (fromUnit.toLowerCase() == 'ml' && toUnit.toLowerCase() == 'liter') return qty / 1000;
    if (fromUnit.toLowerCase() == 'liter' && toUnit.toLowerCase() == 'ml') return qty * 1000;
    return qty; // Unknown unit — return as-is
  }

  Future<void> deleteInventoryItem(String id) async {
    if (AppConfig.useMockData) {
      _inventory.removeWhere((i) => i.id == id);
      notifyListeners();
      return;
    }
    await _firebaseService.deleteInventoryItem(id);
  }

  bool hasEnoughStock(String ingredientId, double requiredQuantity, {String? ingredientName, String? requiredUnit}) {
    // Try to find by ID first
    var item = _inventory.firstWhere((i) => i.id == ingredientId, orElse: () => InventoryItem(id: '', name: '', stock: -1, unit: ''));
    
    // Fallback to finding by name if ID fails or item not found
    if (item.stock == -1 && ingredientName != null) {
      item = _inventory.firstWhere((i) => i.name.toLowerCase() == ingredientName.toLowerCase(), orElse: () => InventoryItem(id: '', name: '', stock: -1, unit: ''));
    }

    if (item.stock == -1) return true; // Assume available if not in inventory system yet

    // Unit Conversion Logic
    double availableStock = item.stock;
    double neededQty = requiredQuantity;

    // Convert everything to a base unit for comparison if units differ
    if (requiredUnit != null && item.unit.toLowerCase() != requiredUnit.toLowerCase()) {
      // KG to GM conversion
      if (item.unit.toLowerCase() == 'kg' && requiredUnit.toLowerCase() == 'gm') {
        availableStock = item.stock * 1000;
      } else if (item.unit.toLowerCase() == 'gm' && requiredUnit.toLowerCase() == 'kg') {
        neededQty = requiredQuantity * 1000;
      }
      // Liter to ML conversion
      else if (item.unit.toLowerCase() == 'liter' && requiredUnit.toLowerCase() == 'ml') {
        availableStock = item.stock * 1000;
      } else if (item.unit.toLowerCase() == 'ml' && requiredUnit.toLowerCase() == 'liter') {
        neededQty = requiredQuantity * 1000;
      }
    }

    return availableStock >= neededQty;
  }
}
