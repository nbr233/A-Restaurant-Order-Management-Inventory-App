import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';

class BillingScreen extends StatefulWidget {
  final OrderModel order;
  const BillingScreen({super.key, required this.order});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController _discountController =
      TextEditingController(text: '0');
  double _discountPercent = 0; // stored as percentage, e.g. 10 = 10%

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.order.status == 'Completed';
    final subtotal = widget.order.subtotal;
    final discount = isCompleted ? widget.order.discount : (subtotal * _discountPercent / 100);
    final vat = isCompleted ? widget.order.vat : ((subtotal - discount) * 0.10);
    final grandTotal = isCompleted ? widget.order.grandTotal : (subtotal - discount + vat);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Bill #${widget.order.id.substring(widget.order.id.length - 4)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Table ${widget.order.tableNumber}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Items header ─────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Item',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Price',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Scrollable items ─────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding, vertical: 4),
              itemCount: widget.order.items.length,
              itemBuilder: (context, index) {
                final item = widget.order.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(
                              '${AppConstants.currencySymbol} ${item.price.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Text('${item.quantity}',
                              textAlign: TextAlign.center)),
                      Expanded(
                        child: Text(
                          '${AppConstants.currencySymbol} ${(item.price * item.quantity).toStringAsFixed(0)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Bottom summary ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.defaultPadding, 16,
                AppConstants.defaultPadding, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Subtotal
                _summaryRow(context, 'Subtotal',
                    '${AppConstants.currencySymbol} ${subtotal.toStringAsFixed(0)}',
                    null),
                const SizedBox(height: 10),

                // Discount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount'),
                    Row(
                      children: [
                        if (!isCompleted)
                          SizedBox(
                            width: 80,
                            height: 36,
                            child: TextField(
                              controller: _discountController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                suffixText: '%',
                                suffixStyle: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 9),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.success, width: 1.5),
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  double p = double.tryParse(val) ?? 0;
                                  if (p < 0) p = 0;
                                  if (p > 100) p = 100;
                                  _discountPercent = p;
                                });
                              },
                            ),
                          ),
                        if (!isCompleted) const SizedBox(width: 8),
                        Text(
                          '- ${AppConstants.currencySymbol} ${discount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // VAT
                _summaryRow(context, 'VAT (10%)',
                    '${AppConstants.currencySymbol} ${vat.toStringAsFixed(0)}',
                    null),

                const Divider(height: 28),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Grand Total',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '${AppConstants.currencySymbol} ${grandTotal.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Confirm button OR PAID stamp
                if (widget.order.status == 'Completed')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF27AE60), width: 2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Color(0xFF27AE60), size: 28),
                        SizedBox(width: 10),
                        Text(
                          'PAID',
                          style: TextStyle(
                            color: Color(0xFF27AE60),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final orderProvider = Provider.of<OrderProvider>(
                          context,
                          listen: false);
                      final tableProvider = Provider.of<TableProvider>(
                          context,
                          listen: false);
                      final menuProvider = Provider.of<MenuProvider>(
                          context,
                          listen: false);
                      final inventoryProvider =
                          Provider.of<InventoryProvider>(context,
                              listen: false);

                      for (var orderItem in widget.order.items) {
                        try {
                          final menuItem = menuProvider.menuItems
                              .firstWhere(
                                  (m) => m.id == orderItem.menuItemId);
                          for (var ingredient in menuItem.recipe) {
                            try {
                              final invItem =
                                  inventoryProvider.inventory.firstWhere(
                                (i) =>
                                    i.id == ingredient.ingredientId ||
                                    i.name.toLowerCase() ==
                                        ingredient.name.toLowerCase(),
                              );
                              double dq =
                                  ingredient.quantity * orderItem.quantity;
                              if (invItem.unit.toLowerCase() !=
                                  ingredient.unit.toLowerCase()) {
                                if (invItem.unit.toLowerCase() == 'kg' &&
                                    ingredient.unit.toLowerCase() == 'gm')
                                  dq /= 1000;
                                else if (invItem.unit.toLowerCase() == 'gm' &&
                                    ingredient.unit.toLowerCase() == 'kg')
                                  dq *= 1000;
                                else if (invItem.unit.toLowerCase() ==
                                        'liter' &&
                                    ingredient.unit.toLowerCase() == 'ml')
                                  dq /= 1000;
                                else if (invItem.unit.toLowerCase() == 'ml' &&
                                    ingredient.unit.toLowerCase() == 'liter')
                                  dq *= 1000;
                              }
                              await inventoryProvider.updateInventoryItem(
                                  invItem.copyWith(
                                      stock: invItem.stock - dq));
                            } catch (_) {}
                          }
                        } catch (_) {}
                      }

                      await orderProvider.completeOrder(
                        orderId: widget.order.id,
                        discount: discount,
                        vat: vat,
                        grandTotal: grandTotal,
                      );
                      await tableProvider.updateTableStatus(
                          widget.order.tableId, 'Available');

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Payment Successful!')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Confirm Payment'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      BuildContext context, String label, String value, Color? color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
