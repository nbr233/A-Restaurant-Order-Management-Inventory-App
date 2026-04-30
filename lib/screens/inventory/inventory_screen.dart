import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../utils/constants.dart';
import '../../models/inventory_item.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Inventory Management', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Summary Stats
          _buildSummaryStats(inventoryProvider),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Inventory List
          Expanded(
            child: inventoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : inventoryProvider.inventory.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                        itemCount: inventoryProvider.inventory.length,
                        itemBuilder: (context, index) {
                          final item = inventoryProvider.inventory[index];
                          return _buildInventoryCard(context, item, inventoryProvider);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInventoryDialog(context),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Ingredient', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryStats(InventoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', provider.inventory.length.toString(), AppColors.primaryColor),
          _buildStatItem('Low Stock', provider.lowStockCount.toString(), AppColors.warning),
          _buildStatItem('Out of Stock', provider.outOfStockCount.toString(), AppColors.error),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildInventoryCard(BuildContext context, InventoryItem item, InventoryProvider provider) {
    Color statusColor;
    switch (item.status) {
      case 'In Stock': statusColor = AppColors.success; break;
      case 'Low Stock': statusColor = AppColors.warning; break;
      case 'Out of Stock': statusColor = AppColors.error; break;
      default: statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.inventory_2_rounded, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${item.stock} ${item.unit}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.textSecondary),
                    onPressed: () => _showInventoryDialog(context, item: item),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    onPressed: () => provider.deleteInventoryItem(item.id),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No items in inventory', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const Text('Add raw materials to start tracking', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  void _showInventoryDialog(BuildContext context, {InventoryItem? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final stockController = TextEditingController(text: item?.stock.toString() ?? '');
    String unit = item?.unit ?? 'kg';
    final List<String> units = ['kg', 'gm', 'liter', 'ml', 'pcs', 'pkt'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Ingredient' : 'Add Ingredient', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ingredient Name', prefixIcon: Icon(Icons.title)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock Quantity', prefixIcon: Icon(Icons.numbers)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: unit,
                    items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (val) => unit = val!,
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || stockController.text.isEmpty) return;
              
              final newItem = InventoryItem(
                id: item?.id ?? '',
                name: nameController.text,
                stock: double.parse(stockController.text),
                unit: unit,
              );

              if (isEditing) {
                context.read<InventoryProvider>().updateInventoryItem(newItem);
              } else {
                context.read<InventoryProvider>().addInventoryItem(newItem);
              }
              Navigator.pop(ctx);
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }
}
