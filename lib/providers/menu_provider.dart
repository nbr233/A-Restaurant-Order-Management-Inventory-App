import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/firebase_service.dart';

import '../config.dart';

class MenuProvider extends ChangeNotifier {
  late final FirebaseService _firebaseService;
  
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String _searchQuery = '';

  List<MenuItem> get menuItems => _filteredItems;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  MenuProvider() {
    if (!AppConfig.useMockData) {
      _firebaseService = FirebaseService();
    }
    _initMenuStream();
  }

  void _initMenuStream() {
    if (AppConfig.useMockData) {
      _menuItems = [
        MenuItem(
          id: '1', 
          name: 'Chicken Burger', 
          category: 'Popular', 
          price: 200, 
          isAvailable: true,
          recipe: [
            RecipeIngredient(ingredientId: 'i3', name: 'Bun', quantity: 1, unit: 'pcs'),
            RecipeIngredient(ingredientId: 'i4', name: 'Chicken', quantity: 0.2, unit: 'kg'),
          ],
        ),
        MenuItem(
          id: '2', 
          name: 'Beef Burger', 
          category: 'Popular', 
          price: 250, 
          isAvailable: true,
          recipe: [
            RecipeIngredient(ingredientId: 'i3', name: 'Bun', quantity: 1, unit: 'pcs'),
          ],
        ),
        MenuItem(id: '3', name: 'Chicken Pizza', category: 'Popular', price: 550, isAvailable: true),
        MenuItem(id: '4', name: 'French Fries', category: 'Menu', price: 150, isAvailable: true),
        MenuItem(id: '5', name: 'Cold Coffee', category: 'Drinks', price: 180, isAvailable: true),
        MenuItem(id: '6', name: 'Orange Juice', category: 'Drinks', price: 120, isAvailable: true),
        MenuItem(id: '7', name: 'Veggie Burger', category: 'Menu', price: 180, isAvailable: true),
        MenuItem(id: '8', name: 'Fish & Chips', category: 'Menu', price: 320, isAvailable: true),
        MenuItem(id: '9', name: 'Pasta Alfredo', category: 'Menu', price: 350, isAvailable: true),
        MenuItem(id: '10', name: 'Burger Combo', category: 'Combos', price: 380, isAvailable: true),
        MenuItem(id: '11', name: 'Family Feast', category: 'Combos', price: 950, isAvailable: true),
        MenuItem(id: '12', name: 'Lemon Tea', category: 'Drinks', price: 80, isAvailable: true),
        MenuItem(id: '13', name: 'Mango Shake', category: 'Drinks', price: 150, isAvailable: true),
        MenuItem(id: '14', name: 'Masala Chai', category: 'Drinks', price: 60, isAvailable: true),
      ];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _firebaseService.getMenuItems().listen((items) {
      _menuItems = items;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<MenuItem> get _filteredItems {
    List<MenuItem> items = _menuItems;
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return items;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // CRUD Operations
  Future<void> addMenuItem(MenuItem item) async {
    if (AppConfig.useMockData) {
      final newItem = item.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      _menuItems.add(newItem);
      notifyListeners();
      return;
    }
    await _firebaseService.addMenuItem(item);
  }

  Future<void> updateMenuItem(MenuItem item) async {
    if (AppConfig.useMockData) {
      final index = _menuItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _menuItems[index] = item;
        notifyListeners();
      }
      return;
    }
    await _firebaseService.updateMenuItem(item);
  }

  Future<void> deleteMenuItem(String id) async {
    if (AppConfig.useMockData) {
      _menuItems.removeWhere((i) => i.id == id);
      notifyListeners();
      return;
    }
    await _firebaseService.deleteMenuItem(id);
  }

  Future<void> toggleAvailability(String id, bool status) async {
    final index = _menuItems.indexWhere((i) => i.id == id);
    if (index != -1) {
      final updatedItem = _menuItems[index].copyWith(isAvailable: status);
      await updateMenuItem(updatedItem);
    }
  }

  // Filter methods
  List<MenuItem> get popularItems => _menuItems.where((item) => item.category == 'Popular').toList();
  List<MenuItem> get drinkItems => _menuItems.where((item) => item.category == 'Drinks').toList();
  List<MenuItem> get comboItems => _menuItems.where((item) => item.category == 'Combos').toList();
  List<MenuItem> itemsByCategory(String category) => _menuItems.where((item) => item.category == category).toList();

  List<MenuItem> getFilteredByCategory(String category, String query) {
    List<MenuItem> items = category == 'All' || category == 'Menu'
        ? _menuItems
        : _menuItems.where((item) => item.category == category).toList();
    if (query != null && query.isNotEmpty) {
      items = items.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    return items;
  }
}
