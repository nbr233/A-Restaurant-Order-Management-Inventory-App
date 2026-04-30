import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';
import '../config.dart';
import 'inventory_provider.dart';
import 'menu_provider.dart';

class OrderProvider extends ChangeNotifier {
  late final FirebaseService _firebaseService;
  
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  // Cart state
  final Map<String, OrderItem> _cartItems = {};
  String? _selectedTableId;
  String? _selectedTableNumber;
  int? _selectedTableSeats;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Map<String, OrderItem> get cartItems => _cartItems;
  String? get selectedTableId => _selectedTableId;
  String? get selectedTableNumber => _selectedTableNumber;
  int? get selectedTableSeats => _selectedTableSeats;

  OrderProvider() {
    if (!AppConfig.useMockData) {
      _firebaseService = FirebaseService();
    }
    _initOrderStream();
  }

  void _initOrderStream() {
    if (AppConfig.useMockData) {
      _orders = [
        OrderModel(
          id: 'ord1',
          tableId: 't3',
          tableNumber: '3',
          items: [
            OrderItem(menuItemId: '1', name: 'Chicken Burger', price: 200, quantity: 2),
            OrderItem(menuItemId: '4', name: 'French Fries', price: 150, quantity: 1),
          ],
          subtotal: 550,
          discount: 0,
          vat: 55,
          grandTotal: 605,
          status: 'Pending',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
        OrderModel(
          id: 'ord2',
          tableId: 't5',
          tableNumber: '5',
          items: [
            OrderItem(menuItemId: '3', name: 'Chicken Pizza', price: 550, quantity: 1),
            OrderItem(menuItemId: '5', name: 'Cold Coffee', price: 180, quantity: 1),
          ],
          subtotal: 730,
          discount: 0,
          vat: 73,
          grandTotal: 803,
          status: 'Pending',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
        ),
        OrderModel(
          id: 'ord3',
          tableId: 't1',
          tableNumber: '1',
          items: [
            OrderItem(menuItemId: '2', name: 'Beef Burger', price: 250, quantity: 3),
            OrderItem(menuItemId: '6', name: 'Orange Juice', price: 120, quantity: 2),
          ],
          subtotal: 990,
          discount: 0,
          vat: 99,
          grandTotal: 1089,
          status: 'Completed',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)).millisecondsSinceEpoch,
        ),
      ];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _firebaseService.getOrders().listen((ordersData) {
      _orders = ordersData;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Cart Management
  void setTable(String tableId, String tableNumber, {int seats = 4, bool loadExisting = true}) {
    _selectedTableId = tableId;
    _selectedTableNumber = tableNumber;
    _selectedTableSeats = seats;
    _cartItems.clear();

    if (loadExisting) {
      final activeOrder = getActiveOrderForTable(tableId);
      if (activeOrder != null) {
        for (var item in activeOrder.items) {
          _cartItems[item.menuItemId] = item;
        }
      }
    }
    
    notifyListeners();
  }

  OrderModel? getActiveOrderForTable(String tableId) {
    try {
      return _orders.firstWhere(
        (o) => o.tableId == tableId && o.status == 'Pending',
      );
    } catch (_) {
      return null;
    }
  }

  void addToCart(String menuItemId, String name, double price) {
    if (_cartItems.containsKey(menuItemId)) {
      _cartItems.update(
        menuItemId,
        (existing) => OrderItem(
          menuItemId: existing.menuItemId,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _cartItems.putIfAbsent(
        menuItemId,
        () => OrderItem(
          menuItemId: menuItemId,
          name: name,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void decrementQuantity(String menuItemId) {
    if (!_cartItems.containsKey(menuItemId)) return;
    
    if (_cartItems[menuItemId]!.quantity > 1) {
      _cartItems.update(
        menuItemId,
        (existing) => OrderItem(
          menuItemId: existing.menuItemId,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _cartItems.remove(menuItemId);
    }
    notifyListeners();
  }

  void removeFromCart(String menuItemId) {
    _cartItems.remove(menuItemId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _selectedTableId = null;
    _selectedTableNumber = null;
    _selectedTableSeats = null;
    notifyListeners();
  }

  double get subtotal {
    double total = 0.0;
    _cartItems.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  int get itemCount {
    int count = 0;
    _cartItems.forEach((key, item) {
      count += item.quantity;
    });
    return count;
  }

  int getItemQuantity(String menuItemId) {
    return _cartItems[menuItemId]?.quantity ?? 0;
  }

  // ── Place order and immediately deduct inventory ──────────────────────
  Future<bool> placeOrderWithInventory(
    InventoryProvider inventoryProvider,
    MenuProvider menuProvider,
  ) async {
    if (_selectedTableId == null || _cartItems.isEmpty) return false;

    // 0. Pre-validate: Check all ingredients have sufficient stock before placing
    for (var orderItem in _cartItems.values) {
      try {
        final menuItem = menuProvider.menuItems.firstWhere(
          (m) => m.id == orderItem.menuItemId,
        );
        for (var ingredient in menuItem.recipe) {
          final hasStock = inventoryProvider.hasEnoughStock(
            ingredient.ingredientId,
            ingredient.quantity * orderItem.quantity,
            ingredientName: ingredient.name,
            requiredUnit: ingredient.unit,
          );
          if (!hasStock) {
            debugPrint('Not enough stock for: ${ingredient.name}');
            return false; // Block order if any ingredient is out of stock
          }
        }
      } catch (_) {
        // Menu item not found — allow order (no recipe linked)
      }
    }

    // 1. Deduct ingredients from inventory immediately on order placement
    for (var orderItem in _cartItems.values) {
      try {
        final menuItem = menuProvider.menuItems.firstWhere(
          (m) => m.id == orderItem.menuItemId,
        );
        for (var ingredient in menuItem.recipe) {
          try {
            final invItem = inventoryProvider.inventory.firstWhere(
              (i) =>
                  i.id == ingredient.ingredientId ||
                  i.name.toLowerCase() == ingredient.name.toLowerCase(),
            );
            double deductQty = ingredient.quantity * orderItem.quantity;

            // Unit conversion
            if (invItem.unit.toLowerCase() != ingredient.unit.toLowerCase()) {
              if (invItem.unit.toLowerCase() == 'kg' &&
                  ingredient.unit.toLowerCase() == 'gm') {
                deductQty = deductQty / 1000;
              } else if (invItem.unit.toLowerCase() == 'gm' &&
                  ingredient.unit.toLowerCase() == 'kg') {
                deductQty = deductQty * 1000;
              } else if (invItem.unit.toLowerCase() == 'liter' &&
                  ingredient.unit.toLowerCase() == 'ml') {
                deductQty = deductQty / 1000;
              } else if (invItem.unit.toLowerCase() == 'ml' &&
                  ingredient.unit.toLowerCase() == 'liter') {
                deductQty = deductQty * 1000;
              }
            }

            final newStock = invItem.stock - deductQty;
            await inventoryProvider.updateInventoryItem(
              invItem.copyWith(stock: newStock),
            );
          } catch (e) {
            debugPrint(
              'Could not deduct inventory for ingredient: ${ingredient.name} - $e',
            );
          }
        }
      } catch (e) {
        debugPrint('Menu item not found for order item: ${orderItem.name}');
      }
    }

    // 2. Create / update the order
    double currentSubtotal = subtotal;
    double discount = 0.0;
    double vat = currentSubtotal * 0.10;
    double grandTotal = currentSubtotal - discount + vat;

    final activeOrder = getActiveOrderForTable(_selectedTableId!);
    final String orderId =
        activeOrder?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final newOrder = OrderModel(
      id: orderId,
      tableId: _selectedTableId!,
      tableNumber: _selectedTableNumber!,
      items: _cartItems.values.toList(),
      subtotal: currentSubtotal,
      discount: discount,
      vat: vat,
      grandTotal: grandTotal,
      status: activeOrder?.status ?? 'Pending',
      timestamp:
          activeOrder?.timestamp ?? DateTime.now().millisecondsSinceEpoch,
    );

    if (AppConfig.useMockData) {
      if (activeOrder != null) {
        final index = _orders.indexWhere((o) => o.id == activeOrder.id);
        if (index != -1) {
          _orders[index] = newOrder;
        }
      } else {
        _orders.insert(0, newOrder);
      }
      clearCart();
      notifyListeners();
      return true;
    }

    try {
      if (activeOrder != null) {
        await _firebaseService.updateOrder(newOrder);
      } else {
        await _firebaseService.createOrder(newOrder);
      }
      await _firebaseService.updateTableStatus(_selectedTableId!, 'Occupied');
      clearCart();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Legacy placeOrder (kept for compatibility) ────────────────────────
  Future<bool> placeOrder() async {
    if (_selectedTableId == null || _cartItems.isEmpty) return false;

    double currentSubtotal = subtotal;
    double discount = 0.0;
    double vat = currentSubtotal * 0.10;
    double grandTotal = currentSubtotal - discount + vat;

    final activeOrder = getActiveOrderForTable(_selectedTableId!);
    final String orderId =
        activeOrder?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final newOrder = OrderModel(
      id: orderId,
      tableId: _selectedTableId!,
      tableNumber: _selectedTableNumber!,
      items: _cartItems.values.toList(),
      subtotal: currentSubtotal,
      discount: discount,
      vat: vat,
      grandTotal: grandTotal,
      status: activeOrder?.status ?? 'Pending',
      timestamp:
          activeOrder?.timestamp ?? DateTime.now().millisecondsSinceEpoch,
    );

    if (AppConfig.useMockData) {
      if (activeOrder != null) {
        final index = _orders.indexWhere((o) => o.id == activeOrder.id);
        if (index != -1) {
          _orders[index] = newOrder;
        }
      } else {
        _orders.insert(0, newOrder);
      }
      clearCart();
      notifyListeners();
      return true;
    }

    try {
      if (activeOrder != null) {
        await _firebaseService.updateOrder(newOrder);
      } else {
        await _firebaseService.createOrder(newOrder);
      }
      await _firebaseService.updateTableStatus(_selectedTableId!, 'Occupied');
      clearCart();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> completeOrder({
    required String orderId,
    required double discount,
    required double vat,
    required double grandTotal,
    String paymentMethod = 'Cash',
  }) async {
    if (AppConfig.useMockData) {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final o = _orders[index];
        _orders[index] = OrderModel(
          id: o.id,
          tableId: o.tableId,
          tableNumber: o.tableNumber,
          items: o.items,
          subtotal: o.subtotal,
          discount: discount,
          vat: vat,
          grandTotal: grandTotal,
          status: 'Completed',
          timestamp: o.timestamp,
          paymentMethod: paymentMethod,
        );
        notifyListeners();
      }
      return;
    }
    // For Firebase, update the entire order or specific fields
    final order = _orders.firstWhere((o) => o.id == orderId);
    final updatedOrder = OrderModel(
      id: order.id,
      tableId: order.tableId,
      tableNumber: order.tableNumber,
      items: order.items,
      subtotal: order.subtotal,
      discount: discount,
      vat: vat,
      grandTotal: grandTotal,
      status: 'Completed',
      timestamp: order.timestamp,
      paymentMethod: paymentMethod,
    );
    await _firebaseService.updateOrder(updatedOrder);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
  }
}
