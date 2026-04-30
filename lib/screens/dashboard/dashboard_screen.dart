import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/table_provider.dart';
import '../../utils/constants.dart';
import '../tables/table_management_screen.dart';
import '../orders/orders_screen.dart';
import '../menu/menu_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    // Calculate totals from orders
    double totalSales = 0.0;
    int pendingOrders = 0;
    for (var order in orderProvider.orders) {
      if (order.status == 'Completed') {
        totalSales += order.grandTotal;
      }
      if (order.status == 'Pending') {
        pendingOrders++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, Admin', style: Theme.of(context).textTheme.titleLarge),
            Text('Good Morning!', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard(context, 'Today\'s Sales', '${AppConstants.currencySymbol} ${totalSales.toStringAsFixed(2)}', '+12.5%', true)),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(child: _buildSummaryCard(context, 'Total Orders', '${orderProvider.orders.length}', '+8.2%', true)),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(child: _buildSummaryCard(context, 'Pending Orders', '$pendingOrders', 'Action Needed', false, isWarning: true)),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(child: _buildSummaryCard(context, 'Low Stock Items', '5', 'Check Inventory', false, isWarning: true)),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding * 2),

            // Quick Actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: AppConstants.defaultPadding * 2),

          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context,
            icon: Icons.table_restaurant_rounded,
            label: 'Table\nManagement',
            subLabel: '${tableProvider.availableCount} Available',
            color: AppColors.primaryColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TableManagementScreen())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            icon: Icons.receipt_long_rounded,
            label: 'View\nOrders',
            subLabel: 'All orders',
            color: const Color(0xFF00897B),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            icon: Icons.restaurant_menu_rounded,
            label: 'Menu\nItems',
            subLabel: 'Manage menu',
            color: const Color(0xFFE91E63),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen())),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, {required IconData icon, required String label, required String subLabel, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: color, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(subLabel, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, String subtitle, bool isPositive, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (!isWarning)
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              if (isWarning)
                const Icon(Icons.warning, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isWarning ? AppColors.warning : (isPositive ? AppColors.success : AppColors.error),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
