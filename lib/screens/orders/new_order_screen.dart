import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../models/menu_item.dart';
import '../../utils/constants.dart';
import 'cart_screen.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen>
    with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<String> _categories = ['Menu', 'Popular', 'Combos', 'Drinks'];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  List<MenuItem> _getFilteredItems(MenuProvider menuProvider) {
    final category = _categories[_selectedCategoryIndex];
    return menuProvider.getFilteredByCategory(category, _searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final tableNumber = orderProvider.selectedTableNumber ?? '?';
    final tableSeats = orderProvider.selectedTableSeats ?? 4;
    final filteredItems = _getFilteredItems(menuProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context, tableNumber, tableSeats, orderProvider),
      body: Column(
        children: [
          // ── Category tabs ──────────────────────────────────────
          _buildCategoryTabs(),

          // ── Search bar ────────────────────────────────────────
          _buildSearchBar(),

          const SizedBox(height: 8),

          // ── Menu list ─────────────────────────────────────────
          Expanded(
            child: menuProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : filteredItems.isEmpty
                    ? _buildEmptySearch()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return _buildMenuItemCard(context, filteredItems[index], orderProvider, inventoryProvider);
                        },
                      ),
          ),
        ],
      ),

      // ── View Cart bottom bar ───────────────────────────────────
      bottomNavigationBar: orderProvider.itemCount > 0
          ? SlideTransition(
              position: _slideAnimation,
              child: _buildCartBar(context, orderProvider),
            )
          : null,
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, String tableNumber, int seats, OrderProvider orderProvider) {
    return AppBar(
      backgroundColor: AppColors.cardColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
        color: AppColors.textPrimary,
      ),
      title: Column(
        children: [
          Text(
            'Table $tableNumber',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Text(
                '$seats Seats',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
              onPressed: orderProvider.itemCount > 0
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))
                  : null,
            ),
            if (orderProvider.itemCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${orderProvider.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.dividerColor, height: 1),
      ),
    );
  }

  // ── Category tabs ────────────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    return Container(
      color: AppColors.cardColor,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_categories.length, (index) {
            final isSelected = _selectedCategoryIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedCategoryIndex = index;
                  _searchController.clear();
                  _searchQuery = '';
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : AppColors.dividerColor,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.cardColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search menu items...',
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          filled: true,
          fillColor: AppColors.backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Menu item card ───────────────────────────────────────────────────
  Widget _buildMenuItemCard(BuildContext context, MenuItem item, OrderProvider orderProvider, InventoryProvider inventoryProvider) {
    final qty = orderProvider.getItemQuantity(item.id);
    final inCart = qty > 0;

    // Real-time stock check from inventory
    bool isAvailable = item.isAvailable;
    if (item.recipe.isNotEmpty) {
      isAvailable = item.recipe.every((ing) =>
        inventoryProvider.hasEnoughStock(
          ing.ingredientId,
          ing.quantity,
          ingredientName: ing.name,
          requiredUnit: ing.unit,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: inCart ? AppColors.primaryColor.withOpacity(0.3) : AppColors.dividerColor,
          width: inCart ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ── Food image / icon ──────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _getCategoryColor(item.category).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                    )
                  : Icon(
                      _getCategoryIcon(item.category),
                      color: _getCategoryColor(item.category),
                      size: 30,
                    ),
            ),
            const SizedBox(width: 14),

            // ── Name & price ──────────────────────────────────
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
                  const SizedBox(height: 4),
                  Text(
                    '${AppConstants.currencySymbol} ${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (!isAvailable)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),

            // ── Qty stepper or Add button ──────────────────────
            if (inCart && isAvailable)
              _buildQtyStepper(item, orderProvider, qty)
            else if (!isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: const Text('Out of Stock', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
              )
            else
              _buildAddButton(item, orderProvider, isAvailable),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(MenuItem item, OrderProvider orderProvider, bool isAvailable) {
    return GestureDetector(
      onTap: isAvailable
          ? () => orderProvider.addToCart(item.id, item.name, item.price)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isAvailable ? AppColors.primaryColor : AppColors.dividerColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildQtyStepper(MenuItem item, OrderProvider orderProvider, int qty) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => orderProvider.decrementQuantity(item.id),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: const Icon(Icons.remove_rounded, size: 16, color: AppColors.textPrimary),
          ),
        ),
        SizedBox(
          width: 32,
          child: Center(
            child: Text(
              '$qty',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => orderProvider.addToCart(item.id, item.name, item.price),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ── Cart bottom bar ──────────────────────────────────────────────────
  Widget _buildCartBar(BuildContext context, OrderProvider orderProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Item count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${orderProvider.itemCount} Items',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${AppConstants.currencySymbol} ${orderProvider.subtotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const Row(
                  children: [
                    Text(
                      'View Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 13),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: AppColors.dividerColor),
          const SizedBox(height: 12),
          Text(
            'No items found for "$_searchQuery"',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Drinks': return const Color(0xFF2196F3);
      case 'Popular': return const Color(0xFFE91E63);
      case 'Combos': return const Color(0xFF9C27B0);
      default: return AppColors.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Drinks': return Icons.local_drink_rounded;
      case 'Popular': return Icons.star_rounded;
      case 'Combos': return Icons.dining_rounded;
      default: return Icons.fastfood_rounded;
    }
  }
}
