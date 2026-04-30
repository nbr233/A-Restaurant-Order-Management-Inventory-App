import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import 'billing_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Completed'];

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':   return AppColors.warning;
      case 'Completed': return Colors.green[800]!;
      case 'Cancelled': return AppColors.error;
      default:          return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    var displayOrders = orderProvider.orders;
    if (_selectedFilter != 'All') {
      displayOrders = displayOrders.where((o) => o.status == _selectedFilter).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: Column(
        children: [
          // ── Filter chips ─────────────────────────────────────────
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding, vertical: 6),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: AppColors.primaryColor,
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal),
                    backgroundColor: AppColors.cardColor,
                  ),
                );
              },
            ),
          ),

          // ── Orders list ──────────────────────────────────────────
          Expanded(
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64,
                                color: AppColors.textSecondary.withOpacity(0.3)),
                            const SizedBox(height: 12),
                            Text('No $_selectedFilter orders',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        itemCount: displayOrders.length,
                        itemBuilder: (context, index) {
                          final order = displayOrders[index];
                          final time =
                              DateTime.fromMillisecondsSinceEpoch(order.timestamp);
                          final formattedTime =
                              '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          BillingScreen(order: order))),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Top row ─────────────────────
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '#${order.id.substring(order.id.length - 4).toUpperCase()}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            Text(formattedTime,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Table ${order.tableNumber}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryColor),
                                          ),
                                        ),
                                        Text(
                                          '${AppConstants.currencySymbol} ${order.grandTotal.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // ── Items preview ───────────────
                                    Text(
                                      order.items
                                          .map((i) =>
                                              '${i.name} ×${i.quantity}')
                                          .join('  •  '),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 10),

                                    // ── Status badge only ────────────
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(order.status)
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _statusColor(order.status),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            order.status,
                                            style: TextStyle(
                                                color: _statusColor(order.status),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
