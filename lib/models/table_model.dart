import 'package:flutter/foundation.dart';

class TableModel {
  final String id;
  final int tableNumber;
  final int seats;
  final String status; // 'Available', 'Occupied', 'Reserved'

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.seats,
    this.status = 'Available',
  });

  factory TableModel.fromMap(String id, Map<dynamic, dynamic> map) {
    try {
      return TableModel(
        id: id,
        tableNumber: map['tableNumber'] is int ? map['tableNumber'] : int.tryParse(map['tableNumber']?.toString() ?? '0') ?? 0,
        seats: map['seats'] is int ? map['seats'] : int.tryParse(map['seats']?.toString() ?? '0') ?? 0,
        status: map['status']?.toString() ?? 'Available',
      );
    } catch (e) {
      debugPrint('Error parsing TableModel: $e');
      return TableModel(id: id, tableNumber: 0, seats: 0, status: 'Available');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'tableNumber': tableNumber,
      'seats': seats,
      'status': status,
    };
  }
}
