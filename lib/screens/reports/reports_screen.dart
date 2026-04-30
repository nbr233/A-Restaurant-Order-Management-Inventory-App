import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    double totalSales = 0.0;
    int totalOrders = 0;
    for (var order in orderProvider.orders) {
      if (order.status == 'Completed') {
        totalSales += order.grandTotal;
        totalOrders++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: const Text('This Week', style: TextStyle(color: AppColors.textPrimary)),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(child: _buildReportCard(context, 'Total Sales', '${AppConstants.currencySymbol} ${totalSales.toStringAsFixed(0)}', '+15.2%')),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(child: _buildReportCard(context, 'Total Orders', '$totalOrders', '+10.5%')),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding * 2),

            // Bar Chart
            Text('Sales Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppConstants.defaultPadding),
            Container(
              height: 250,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: const Center(
                child: Icon(Icons.bar_chart, size: 64, color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, String value, String subtitle) {
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
              const Icon(Icons.arrow_upward, size: 14, color: AppColors.success),
              const SizedBox(width: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }
}
