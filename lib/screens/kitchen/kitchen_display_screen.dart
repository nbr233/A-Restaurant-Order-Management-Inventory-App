import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';

class KitchenDisplayScreen extends StatelessWidget {
  const KitchenDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    // Filter orders for kitchen (exclude Completed/Cancelled)
    final kitchenOrders = orderProvider.orders.where((o) => o.status != 'Completed' && o.status != 'Cancelled').toList();
    final pendingCount = kitchenOrders.where((o) => o.status == 'Pending').length;
    final cookingCount = kitchenOrders.where((o) => o.status == 'Cooking').length;
    final readyCount = kitchenOrders.where((o) => o.status == 'Ready').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display (KDS)'),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('All (${kitchenOrders.length})', true),
                _buildFilterChip('Pending ($pendingCount)', false),
                _buildFilterChip('Cooking ($cookingCount)', false),
                _buildFilterChip('Ready ($readyCount)', false),
              ],
            ),
          ),
          
          // Orders List
          Expanded(
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: kitchenOrders.length,
                    itemBuilder: (context, index) {
                      final order = kitchenOrders[index];
                      return _buildOrderCard(context, order, orderProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? AppColors.primaryColor : AppColors.cardColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AppColors.primaryColor : AppColors.dividerColor),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, OrderProvider orderProvider) {
    Color statusColor;
    String actionText;
    String nextStatus;
    
    switch (order.status) {
      case 'Pending':
        statusColor = AppColors.warning;
        actionText = 'Start Cooking';
        nextStatus = 'Cooking';
        break;
      case 'Cooking':
        statusColor = AppColors.info;
        actionText = 'Mark as Ready';
        nextStatus = 'Ready';
        break;
      case 'Ready':
        statusColor = AppColors.success;
        actionText = 'Completed';
        nextStatus = 'Completed';
        break;
      default:
        statusColor = AppColors.textSecondary;
        actionText = '';
        nextStatus = '';
    }

    final time = DateTime.fromMillisecondsSinceEpoch(order.timestamp);
    final formattedTime = '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order.id.substring(order.id.length - 4)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Table ${order.tableNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Text(formattedTime, style: Theme.of(context).textTheme.bodySmall),
            const Divider(height: 24),
            
            // Items
            ...order.items.map<Widget>((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                  Expanded(child: Text(item.name)),
                  Text('x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )).toList(),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
                if (actionText.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      orderProvider.updateOrderStatus(order.id, nextStatus);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: Text(actionText, style: const TextStyle(fontSize: 14)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
