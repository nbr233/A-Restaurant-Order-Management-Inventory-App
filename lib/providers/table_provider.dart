import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../services/firebase_service.dart';

import '../config.dart';

class TableProvider extends ChangeNotifier {
  late final FirebaseService _firebaseService;
  
  List<TableModel> _tables = [];
  bool _isLoading = true;
  String _filterStatus = 'All';

  List<TableModel> get tables => _filteredTables;
  bool get isLoading => _isLoading;
  String get filterStatus => _filterStatus;

  TableProvider() {
    if (!AppConfig.useMockData) {
      _firebaseService = FirebaseService();
    }
    _initTableStream();
  }

  void _initTableStream() {
    if (AppConfig.useMockData) {
      _tables = [
        TableModel(id: 't1', tableNumber: 1, seats: 2, status: 'Occupied'),
        TableModel(id: 't2', tableNumber: 2, seats: 4, status: 'Occupied'),
        TableModel(id: 't3', tableNumber: 3, seats: 4, status: 'Occupied'),
        TableModel(id: 't4', tableNumber: 4, seats: 4, status: 'Available'),
        TableModel(id: 't5', tableNumber: 5, seats: 4, status: 'Occupied'),
        TableModel(id: 't6', tableNumber: 6, seats: 6, status: 'Available'),
        TableModel(id: 't7', tableNumber: 7, seats: 4, status: 'Available'),
        TableModel(id: 't8', tableNumber: 8, seats: 4, status: 'Occupied'),
        TableModel(id: 't9', tableNumber: 9, seats: 2, status: 'Available'),
        TableModel(id: 't10', tableNumber: 10, seats: 6, status: 'Available'),
        TableModel(id: 't11', tableNumber: 11, seats: 4, status: 'Reserved'),
        TableModel(id: 't12', tableNumber: 12, seats: 4, status: 'Available'),
      ];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _firebaseService.getTables().listen((tablesData) {
      _tables = tablesData;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<TableModel> get _filteredTables {
    if (_filterStatus == 'All') return _tables;
    return _tables.where((t) => t.status == _filterStatus).toList();
  }

  List<TableModel> get allTables => _tables;

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> updateTableStatus(String tableId, String status) async {
    if (AppConfig.useMockData) {
      final index = _tables.indexWhere((t) => t.id == tableId);
      if (index != -1) {
        _tables[index] = TableModel(
          id: _tables[index].id,
          tableNumber: _tables[index].tableNumber,
          seats: _tables[index].seats,
          status: status,
        );
        notifyListeners();
      }
      return;
    }
    await _firebaseService.updateTableStatus(tableId, status);
  }

  Future<void> seedTables() async {
    if (AppConfig.useMockData) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      for (int i = 1; i <= 10; i++) {
        final table = TableModel(
          id: 'table_$i',
          tableNumber: i,
          seats: i <= 4 ? 2 : (i <= 8 ? 4 : 6),
          status: 'Available',
        );
        await _firebaseService.createTable(table);
      }
    } catch (e) {
      print('Error seeding tables: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  int get availableCount => _tables.where((t) => t.status == 'Available').length;
  int get occupiedCount => _tables.where((t) => t.status == 'Occupied').length;
  int get reservedCount => _tables.where((t) => t.status == 'Reserved').length;
}
