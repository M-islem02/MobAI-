import 'package:flutter/material.dart';
import '../models/admin_data.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late List<Product> _products;
  String _search = '';
  String _categoryFilter = 'all';
  String _statusFilter = 'all';
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _products = MockDataGenerator.generateProducts();
  }

  List<Product> get _filtered {
    return _products.where((p) {
      if (_categoryFilter != 'all' && p.category != _categoryFilter) return false;
      if (_statusFilter != 'all' && p.status != _statusFilter) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return p.sku.toLowerCase().contains(q) || p.name.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  List<String> get _categories => _products.map((p) => p.category).toSet().toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildToolbar(),
          const SizedBox(height: 14),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260, height: 40,
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by SKU or name...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textLight),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true, fillColor: AppColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          _filterChip('Category', _categoryFilter, [
            const DropdownMenuItem(value: 'all', child: Text('All Categories')),
            ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
          ], (v) => setState(() => _categoryFilter = v!)),
          _filterChip('Status', _statusFilter, const [
            DropdownMenuItem(value: 'all', child: Text('All Status')),
            DropdownMenuItem(value: 'in-stock', child: Text('In Stock')),
            DropdownMenuItem(value: 'low-stock', child: Text('Low Stock')),
            DropdownMenuItem(value: 'out-of-stock', child: Text('Out of Stock')),
          ], (v) => setState(() => _statusFilter = v!)),
          // Summary chips
          _summaryChip('${_products.length}', 'Products', AppColors.primary),
          _summaryChip('${_products.where((p) => p.status == 'low-stock').length}', 'Low Stock', AppColors.accent),
          _summaryChip('${_products.where((p) => p.status == 'out-of-stock').length}', 'Out', AppColors.error),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, List<DropdownMenuItem<String>> items, ValueChanged<String?> onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _summaryChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ]),
    );
  }

  Widget _buildProductList() {
    final list = _filtered;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: list.isEmpty
          ? const Center(child: Text('No products found', style: TextStyle(color: AppColors.textLight)))
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (_, i) => _buildProductRow(list[i]),
            ),
    );
  }

  Widget _buildProductRow(Product p) {
    final isExpanded = _expandedId == p.id;
    return InkWell(
      onTap: () => setState(() => _expandedId = isExpanded ? null : p.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        color: isExpanded ? AppColors.primary.withValues(alpha: 0.04) : Colors.transparent,
        child: Column(
          children: [
            Row(children: [
              // SKU badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(6)),
                child: Text(p.sku, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMid, fontFamily: 'monospace')),
              ),
              const SizedBox(width: 12),
              // Name + Category
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  Text(p.category, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                ]),
              ),
              // Qty
              Column(children: [
                Text('${p.quantity}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: p.statusColor)),
                const Text('qty', style: TextStyle(fontSize: 9, color: AppColors.textLight)),
              ]),
              const SizedBox(width: 16),
              // Status
              _statusBadge(p.statusLabel, p.statusColor),
              const SizedBox(width: 12),
              // Location
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 3),
                  Text(p.locationLabel, style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
                ]),
              ),
              const SizedBox(width: 8),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textLight),
            ]),
            // Expanded detail
            if (isExpanded) ...[
              const SizedBox(height: 14),
              _buildExpandedDetail(p),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetail(Product p) {
    final stockPercent = p.maxStock > 0 ? (p.quantity / p.maxStock).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: _detailItem('Price', '${p.price.toStringAsFixed(0)} DA')),
            Expanded(child: _detailItem('Min Stock', '${p.minStock}')),
            Expanded(child: _detailItem('Max Stock', '${p.maxStock}')),
            Expanded(child: _detailItem('Last Updated', _fmtDate(p.lastUpdated))),
          ]),
          const SizedBox(height: 14),
          // Stock level bar
          Row(children: [
            const Text('Stock Level', style: TextStyle(fontSize: 11, color: AppColors.textMid)),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stockPercent,
                  minHeight: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation(p.statusColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${(stockPercent * 100).toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: p.statusColor)),
          ]),
          const SizedBox(height: 14),
          // AI Demand Forecast (mock)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.aiBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.aiBlue.withValues(alpha: 0.15)),
            ),
            child: Row(children: [
              const Icon(Icons.psychology_rounded, size: 16, color: AppColors.aiBlue),
              const SizedBox(width: 8),
              const Expanded(child: Text('AI Forecast: Demand expected to increase 15% next month', style: TextStyle(fontSize: 11, color: AppColors.aiBlue))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.aiBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: const Text('89% conf.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.aiBlue)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ],
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
