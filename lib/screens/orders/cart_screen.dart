import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/menu_provider.dart';
import '../../utils/constants.dart';
import '../tables/table_management_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isPlacing = false;

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    final double sub = orderProvider.subtotal;
    final double discount = 0.0;
    final double vat = sub * 0.10;
    final double total = sub - discount + vat;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Column(
          children: [
            const Text(
              'Your Order',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Table ${orderProvider.selectedTableNumber ?? '-'}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.dividerColor, height: 1),
        ),
      ),
      body: Column(
        children: [
          // ── Cart items list ──────────────────────────────────
          Expanded(
            child: orderProvider.cartItems.isEmpty
                ? _buildEmptyCart()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: orderProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final key = orderProvider.cartItems.keys.elementAt(index);
                      final item = orderProvider.cartItems[key]!;
                      return _buildCartItem(context, key, item, orderProvider);
                    },
                  ),
          ),

          // ── Totals & Place Order ─────────────────────────────
          _buildTotalsSection(context, orderProvider, sub, discount, vat, total),
        ],
      ),
    );
  }

  // ── Cart item card ───────────────────────────────────────────────────
  Widget _buildCartItem(BuildContext context, String key, dynamic item, OrderProvider orderProvider) {
    return Dismissible(
      key: Key(key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 26),
      ),
      onDismissed: (_) => orderProvider.removeFromCart(key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Colored dot
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fastfood_rounded, color: AppColors.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Name + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${AppConstants.currencySymbol} ${item.price.toStringAsFixed(0)} × ${item.quantity}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Qty stepper
            Row(
              children: [
                _qtyButton(
                  icon: Icons.remove_rounded,
                  onTap: () => orderProvider.decrementQuantity(key),
                  filled: false,
                ),
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                _qtyButton(
                  icon: Icons.add_rounded,
                  onTap: () => orderProvider.addToCart(key, item.name, item.price),
                  filled: true,
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Item total
            Text(
              '${AppConstants.currencySymbol} ${(item.price * item.quantity).toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap, required bool filled}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryColor : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(7),
          border: filled ? null : Border.all(color: AppColors.dividerColor),
        ),
        child: Icon(icon, size: 14, color: filled ? Colors.white : AppColors.textPrimary),
      ),
    );
  }

  // ── Totals section ───────────────────────────────────────────────────
  Widget _buildTotalsSection(
    BuildContext context,
    OrderProvider orderProvider,
    double sub,
    double discount,
    double vat,
    double total,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          _buildPriceLine('Subtotal', '${AppConstants.currencySymbol} ${sub.toStringAsFixed(0)}', null),
          const SizedBox(height: 10),
          _buildPriceLine(
            'Discount',
            discount > 0 ? '- ${AppConstants.currencySymbol} ${discount.toStringAsFixed(0)}' : '${AppConstants.currencySymbol} 0',
            discount > 0 ? AppColors.success : null,
          ),
          const SizedBox(height: 10),
          _buildPriceLine('VAT (10%)', '${AppConstants.currencySymbol} ${vat.toStringAsFixed(0)}', null),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol} ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cancel + Place Order buttons
          Row(
            children: [
              // Cancel
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    orderProvider.clearCart();
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.dividerColor, width: 1.5),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Place Order
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isPlacing ? null : () => _handlePlaceOrder(context, orderProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
                  ),
                  child: _isPlacing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          orderProvider.getActiveOrderForTable(orderProvider.selectedTableId ?? '') != null
                              ? 'Update Order'
                              : 'Place Order',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine(String label, String value, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 72, color: AppColors.dividerColor),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items from the menu to get started',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to Menu', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlaceOrder(BuildContext context, OrderProvider orderProvider) async {
    setState(() => _isPlacing = true);

    // Capture context-dependent objects before async gap
    final tableProvider = context.read<TableProvider>();
    final inventoryProvider = context.read<InventoryProvider>();
    final menuProvider = context.read<MenuProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final tableId = orderProvider.selectedTableId;

    if (tableId != null) {
      await tableProvider.updateTableStatus(tableId, 'Occupied');
    }

    final isUpdate = orderProvider.getActiveOrderForTable(tableId ?? '') != null;

    // Place order AND deduct inventory immediately
    final success = await orderProvider.placeOrderWithInventory(
      inventoryProvider,
      menuProvider,
    );
    if (!mounted) return;

    setState(() => _isPlacing = false);

    if (success) {
      _showSuccessDialog(context, isUpdate);
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('❌ অর্ডার দেওয়া যায়নি! কিছু উপাদানের স্টক শেষ হয়ে গেছে।'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessDialog(BuildContext context, bool isUpdate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                isUpdate ? 'Order Updated!' : 'Order Placed!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                isUpdate
                    ? 'The items have been added to the table\'s order.'
                    : 'Your order has been sent to the kitchen.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // close dialog
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
