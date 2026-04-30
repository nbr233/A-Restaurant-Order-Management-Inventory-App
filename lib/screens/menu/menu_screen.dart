import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_item.dart';
import '../../utils/constants.dart';
import '../../models/menu_item.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All Items';
  String _searchQuery = '';
  final List<String> _categories = ['All Items', 'Popular', 'Burgers', 'Pizza', 'Drinks', 'Snacks', 'Desserts', 'Combos'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    
    // Filter items based on category and search query
    var displayItems = menuProvider.getFilteredByCategory(_selectedCategory == 'All Items' ? 'All' : _selectedCategory, _searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management', style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => menuProvider.notifyListeners(), // Simple refresh
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Add Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search delicious food...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryColor),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          }) 
                        : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.cardColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories Sidebar
                Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor.withOpacity(0.5),
                    border: Border(right: BorderSide(color: AppColors.dividerColor, width: 0.5)),
                  ),
                  child: ListView.builder(
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          onTap: () {
                            setState(() => _selectedCategory = category);
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                // Items List
                Expanded(
                  child: menuProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : displayItems.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppConstants.defaultPadding),
                              itemCount: displayItems.length,
                              itemBuilder: (context, index) {
                                final item = displayItems[index];
                                return _buildMenuCard(context, item, menuProvider);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, MenuItem item, MenuProvider provider) {
    final inventoryProvider = context.watch<InventoryProvider>();
    
    // Check if item is available based on recipe and inventory
    bool isStockAvailable = true;
    for (var ing in item.recipe) {
      if (!inventoryProvider.hasEnoughStock(
        ing.ingredientId, 
        ing.quantity, 
        ingredientName: ing.name,
        requiredUnit: ing.unit,
      )) {
        isStockAvailable = false;
        break;
      }
    }

    final bool effectivelyAvailable = item.isAvailable && isStockAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                image: item.imageUrl != null 
                  ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                  : null,
              ),
              child: item.imageUrl == null 
                ? const Icon(Icons.fastfood_rounded, color: AppColors.primaryColor, size: 28)
                : null,
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            subtitle: Row(
              children: [
                Text(
                  '${AppConstants.currencySymbol}${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: effectivelyAvailable 
                      ? AppColors.success.withOpacity(0.1) 
                      : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    effectivelyAvailable ? 'AVAILABLE' : 'OUT OF STOCK',
                    style: TextStyle(
                      color: effectivelyAvailable ? AppColors.success : AppColors.error,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Switch.adaptive(
              value: item.isAvailable,
              activeColor: AppColors.success,
              onChanged: (val) => provider.toggleAvailability(item.id, val),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context, item, provider),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                      label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showItemDialog(context, item: item),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Edit Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        foregroundColor: AppColors.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No items found', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Try adjusting your search or category', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  void _showItemDialog(BuildContext context, {MenuItem? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    
    // Ensure initial category is valid for the dropdown
    final List<String> validCategories = _categories.where((c) => c != 'All Items' && c != 'Popular').toList();
    String category = item?.category ?? (_selectedCategory == 'All Items' || _selectedCategory == 'Popular' ? 'Burgers' : _selectedCategory);
    if (!validCategories.contains(category)) category = 'Burgers';

    List<RecipeIngredient> tempRecipe = item != null ? List.from(item.recipe) : [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Menu Item' : 'Add New Item', style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Item Name', prefixIcon: Icon(Icons.title)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price', prefixIcon: Icon(Icons.attach_money)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                    items: validCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => category = val!,
                  ),
                  const SizedBox(height: 24),
                  const Text('Recipe / Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  ...tempRecipe.map((ing) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(ing.name),
                    subtitle: Text('${ing.quantity} ${ing.unit} required'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                      onPressed: () {
                        setDialogState(() => tempRecipe.remove(ing));
                      },
                    ),
                  )).toList(),
                  TextButton.icon(
                    onPressed: () => _showAddIngredientDialog(context, (newIng) {
                      setDialogState(() {
                        tempRecipe.removeWhere((i) => i.ingredientId == newIng.ingredientId);
                        tempRecipe.add(newIng);
                      });
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Ingredient'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || priceController.text.isEmpty) return;
                
                final newItem = MenuItem(
                  id: item?.id ?? '',
                  name: nameController.text,
                  category: category,
                  price: double.parse(priceController.text),
                  isAvailable: item?.isAvailable ?? true,
                  imageUrl: item?.imageUrl,
                  recipe: tempRecipe,
                );

                if (isEditing) {
                  context.read<MenuProvider>().updateMenuItem(newItem);
                } else {
                  context.read<MenuProvider>().addMenuItem(newItem);
                }
                Navigator.pop(ctx);
              },
              child: Text(isEditing ? 'Save Changes' : 'Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddIngredientDialog(BuildContext context, Function(RecipeIngredient) onAdd) {
    final inventory = context.read<InventoryProvider>().inventory;
    InventoryItem? selectedItem;
    final qtyController = TextEditingController();
    String selectedUnit = 'kg';
    final List<String> units = ['kg', 'gm', 'liter', 'ml', 'pcs', 'pkt'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Ingredient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<InventoryItem>(
                items: inventory.map((i) => DropdownMenuItem(value: i, child: Text(i.name))).toList(),
                onChanged: (val) {
                  setDialogState(() {
                    selectedItem = val;
                    if (val != null) selectedUnit = val.unit;
                  });
                },
                decoration: const InputDecoration(labelText: 'Item', prefixIcon: Icon(Icons.inventory_2_outlined)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity', prefixIcon: Icon(Icons.numbers)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) => setDialogState(() => selectedUnit = val!),
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
                if (selectedItem != null && qtyController.text.isNotEmpty) {
                  final qty = double.tryParse(qtyController.text);
                  if (qty != null) {
                    onAdd(RecipeIngredient(
                      ingredientId: selectedItem!.id,
                      name: selectedItem!.name,
                      quantity: qty,
                      unit: selectedUnit,
                    ));
                    Navigator.pop(ctx);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, MenuItem item, MenuProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to remove ${item.name} from the menu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteMenuItem(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
