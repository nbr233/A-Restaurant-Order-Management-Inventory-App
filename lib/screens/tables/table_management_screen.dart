import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/table_model.dart';
import '../../utils/constants.dart';
import '../orders/new_order_screen.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Available', 'Occupied', 'Reserved'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProvider>(context);
    final allTables = tableProvider.allTables;

    // Compute counts from allTables directly
    int totalCount = allTables.length;
    int availableCount = allTables.where((t) => t.status == 'Available').length;
    int occupiedCount = allTables.where((t) => t.status == 'Occupied').length;
    int reservedCount = allTables.where((t) => t.status == 'Reserved').length;

    // Filtered list
    List<TableModel> displayTables = _selectedFilter == 'All'
        ? allTables
        : allTables.where((t) => t.status == _selectedFilter).toList();

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
        title: const Text(
          'Table Management',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!tableProvider.isLoading && allTables.isEmpty)
            TextButton.icon(
              onPressed: () => tableProvider.seedTables(),
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Setup'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
            ),
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 24, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.dividerColor, height: 1),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // ── Summary strip ──────────────────────────────────────
            _buildSummaryStrip(totalCount, availableCount, occupiedCount, reservedCount),

            // ── Filter chips ───────────────────────────────────────
            _buildFilterRow(totalCount, availableCount, occupiedCount, reservedCount),

            // ── Table grid ─────────────────────────────────────────
            Expanded(
              child: tableProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : displayTables.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.88,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: displayTables.length,
                          itemBuilder: (context, index) {
                            return _buildTableCard(context, displayTables[index]);
                          },
                        ),
            ),
          ],
        ),
      ),

    );
  }

  // ── Summary strip ────────────────────────────────────────────────────
  Widget _buildSummaryStrip(int total, int available, int occupied, int reserved) {
    return Container(
      color: AppColors.cardColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _buildSummaryItem('Total', total.toString(), AppColors.primaryColor),
          _buildSummaryDivider(),
          _buildSummaryItem('Available', available.toString(), AppColors.tableAvailableText),
          _buildSummaryDivider(),
          _buildSummaryItem('Occupied', occupied.toString(), AppColors.tableOccupiedText),
          _buildSummaryDivider(),
          _buildSummaryItem('Reserved', reserved.toString(), AppColors.tableReservedText),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSummaryDivider() {
    return Container(width: 1, height: 32, color: AppColors.dividerColor);
  }

  // ── Filter row ───────────────────────────────────────────────────────
  Widget _buildFilterRow(int total, int available, int occupied, int reserved) {
    final counts = {'All': total, 'Available': available, 'Occupied': occupied, 'Reserved': reserved};

    return Container(
      color: AppColors.cardColor,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            Color chipColor = AppColors.primaryColor;
            if (filter == 'Available') chipColor = AppColors.tableAvailableText;
            if (filter == 'Occupied') chipColor = AppColors.tableOccupiedText;
            if (filter == 'Reserved') chipColor = AppColors.tableReservedText;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedFilter = filter);
                  context.read<TableProvider>().setFilter(filter);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? chipColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? chipColor : AppColors.dividerColor,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '$filter (${counts[filter]})',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Table card ───────────────────────────────────────────────────────
  Widget _buildTableCard(BuildContext context, TableModel table) {
    final statusConfig = _getStatusConfig(table.status);
    final orderProvider = context.watch<OrderProvider>();
    final activeOrder = orderProvider.getActiveOrderForTable(table.id);

    return GestureDetector(
      onTap: () => _showTableActionSheet(context, table),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (statusConfig['borderColor'] as Color),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity), // Force column width
                // Table icon with colored bg
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (statusConfig['bgColor'] as Color),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.table_restaurant_rounded,
                    color: (statusConfig['textColor'] as Color),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Table ${table.tableNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      '${table.seats} Seats',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (statusConfig['bgColor'] as Color),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    table.status,
                    style: TextStyle(
                      color: (statusConfig['textColor'] as Color),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (activeOrder != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${activeOrder.items.length} Items',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${AppConstants.currencySymbol}${activeOrder.grandTotal.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'Occupied':
        return {
          'bgColor': AppColors.tableOccupied,
          'textColor': AppColors.tableOccupiedText,
          'borderColor': const Color(0xFFFFCDD2),
        };
      case 'Reserved':
        return {
          'bgColor': AppColors.tableReserved,
          'textColor': AppColors.tableReservedText,
          'borderColor': const Color(0xFFFFE0B2),
        };
      default: // Available
        return {
          'bgColor': AppColors.tableAvailable,
          'textColor': AppColors.tableAvailableText,
          'borderColor': const Color(0xFFC8E6C9),
        };
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_restaurant_outlined, size: 64, color: AppColors.dividerColor),
          const SizedBox(height: 16),
          Text(
            'No tables found',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ── Table action bottom sheet ────────────────────────────────────────
  void _showTableActionSheet(BuildContext context, TableModel table) {
    final statusConfig = _getStatusConfig(table.status);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Table info header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (statusConfig['bgColor'] as Color),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.table_restaurant_rounded,
                      color: (statusConfig['textColor'] as Color),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table ${table.tableNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${table.seats} Seats', style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: (statusConfig['bgColor'] as Color),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              table.status,
                              style: TextStyle(
                                color: (statusConfig['textColor'] as Color),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 20),

              // Actions
              if (table.status == 'Available') ...[
                _buildActionButton(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'New Order for This Table',
                  color: AppColors.primaryColor,
                  onTap: () {
                    Navigator.pop(ctx);
                    _navigateToNewOrder(context, table);
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Mark as Reserved',
                  color: AppColors.tableReservedText,
                  onTap: () {
                    context.read<TableProvider>().updateTableStatus(table.id, 'Reserved');
                    Navigator.pop(ctx);
                  },
                ),
              ] else if (table.status == 'Occupied') ...[
                _buildActionButton(
                  icon: Icons.receipt_long_rounded,
                  label: 'View / Add to Order',
                  color: AppColors.primaryColor,
                  onTap: () {
                    Navigator.pop(ctx);
                    _navigateToNewOrder(context, table);
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Mark as Available',
                  color: AppColors.tableAvailableText,
                  onTap: () {
                    context.read<TableProvider>().updateTableStatus(table.id, 'Available');
                    Navigator.pop(ctx);
                  },
                ),
              ] else if (table.status == 'Reserved') ...[
                _buildActionButton(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Seat Guest – New Order',
                  color: AppColors.primaryColor,
                  onTap: () {
                    context.read<TableProvider>().updateTableStatus(table.id, 'Occupied');
                    Navigator.pop(ctx);
                    _navigateToNewOrder(context, table);
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.cancel_outlined,
                  label: 'Cancel Reservation',
                  color: AppColors.error,
                  onTap: () {
                    context.read<TableProvider>().updateTableStatus(table.id, 'Available');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.5), size: 14),
          ],
        ),
      ),
    );
  }

  // ── Table picker for New Order ────────────────────────────────────────
  void _showTablePickerForNewOrder(BuildContext context, List<TableModel> allTables) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollCtrl) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select a Table',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${allTables.where((t) => t.status == 'Available').length} tables available',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: allTables.length,
                      itemBuilder: (_, i) {
                        final table = allTables[i];
                        final statusCfg = _getStatusConfig(table.status);
                        final activeOrder = context.read<OrderProvider>().getActiveOrderForTable(table.id);
                        
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _navigateToNewOrder(context, table);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: (statusCfg['bgColor'] as Color),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: (statusCfg['borderColor'] as Color), width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.table_restaurant_rounded, color: (statusCfg['textColor'] as Color), size: 24),
                                const SizedBox(height: 4),
                                Text('Table ${table.tableNumber}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
                                Text(
                                  activeOrder != null ? '${activeOrder.items.length} Items' : table.status,
                                  style: TextStyle(fontSize: 10, color: (statusCfg['textColor'] as Color), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToNewOrder(BuildContext context, TableModel table) {
    context.read<OrderProvider>().setTable(table.id, table.tableNumber.toString(), seats: table.seats);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewOrderScreen()),
    );
  }
}
