import 'package:flutter/material.dart';
import '../models/admin_data.dart';
import '../widgets/mini_charts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = MockDataGenerator.dashboardMetrics();
    final orders = MockDataGenerator.generateOrders();
    final movements = MockDataGenerator.generateStockMovements();
    final breakdown = MockDataGenerator.generateInventoryBreakdown();
    final decisions = MockDataGenerator.generateAiDecisions();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ═══ STAT CARDS ═══
        _buildStatCards(metrics, decisions),
        const SizedBox(height: 20),

        // ═══ CHARTS ROW ═══
        LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildStockMovementCard(movements)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildInventoryBreakdownCard(breakdown)),
              ],
            );
          }
          return Column(children: [
            _buildStockMovementCard(movements),
            const SizedBox(height: 16),
            _buildInventoryBreakdownCard(breakdown),
          ]);
        }),
        const SizedBox(height: 20),

        // ═══ RECENT ORDERS TABLE ═══
        _buildRecentOrdersCard(orders),
      ],
    );
  }

  // ═══════════════════ STAT CARDS ═══════════════════

  Widget _buildStatCards(Map<String, dynamic> m, List<AiDecision> decisions) {
    final overrideCount = decisions.where((d) => d.status == 'overridden').length;
    final cards = [
      _StatData(Icons.inventory_2_rounded, 'Total Stock', '${m['totalStock']}', '+12%', AppColors.primary),
      _StatData(Icons.local_shipping_rounded, 'Active Orders', '${m['activeOrders']}', '+2', AppColors.aiBlue),
      _StatData(Icons.compare_arrows_rounded, 'Overrides', '$overrideCount', '−1', AppColors.accent),
      _StatData(Icons.psychology_rounded, 'AI Accuracy', '${m['aiAccuracy']}%', '+2.3%', AppColors.success),
      _StatData(Icons.monitor_heart_rounded, 'System Health', '${m['systemHealth']}%', 'Stable', AppColors.primaryDark),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxis = constraints.maxWidth > 1000 ? 5 : constraints.maxWidth > 600 ? 3 : 2;
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: cards.map((c) {
          final width = (constraints.maxWidth - 14 * (crossAxis - 1)) / crossAxis;
          return SizedBox(
            width: width,
            child: _buildStatCard(c),
          );
        }).toList(),
      );
    });
  }

  Widget _buildStatCard(_StatData data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 20, color: data.color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(data.trend, style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(data.value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(data.label, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        ],
      ),
    );
  }

  // ═══════════════════ STOCK MOVEMENT CHART ═══════════════════

  Widget _buildStockMovementCard(List<ChartPoint> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Stock Movements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                child: const Text('12 months', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SparkAreaChart(
            data: data.map((p) => p.value).toList(),
            labels: data.map((p) => p.label).toList(),
            color: AppColors.primary,
            height: 180,
          ),
        ],
      ),
    );
  }

  // ═══════════════════ INVENTORY BREAKDOWN ═══════════════════

  Widget _buildInventoryBreakdownCard(List<ChartPoint> data) {
    final total = data.fold<double>(0, (s, p) => s + p.value);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_rounded, size: 18, color: AppColors.accent),
              SizedBox(width: 8),
              Text('Inventory Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: DonutChart(
              segments: data.map((p) => DonutSegment(p.label, p.value, p.color ?? AppColors.archived)).toList(),
              size: 150,
              centerValue: total.toStringAsFixed(0),
              centerLabel: 'items',
            ),
          ),
          const SizedBox(height: 16),
          ...data.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: p.color ?? AppColors.archived, borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(p.label, style: const TextStyle(fontSize: 12, color: AppColors.textMid))),
                    Text(p.value.toStringAsFixed(0), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ═══════════════════ RECENT ORDERS TABLE ═══════════════════

  Widget _buildRecentOrdersCard(List<OrderEntry> orders) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.aiBlue),
              SizedBox(width: 8),
              Text('Recent Orders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 42,
              dataRowMinHeight: 42,
              dataRowMaxHeight: 48,
              columnSpacing: 28,
              headingTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMid),
              dataTextStyle: const TextStyle(fontSize: 12, color: AppColors.textDark),
              columns: const [
                DataColumn(label: Text('Order')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Items'), numeric: true),
                DataColumn(label: Text('Total'), numeric: true),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Date')),
              ],
              rows: orders.map((o) => DataRow(cells: [
                DataCell(Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(o.customer)),
                DataCell(Text('${o.items}')),
                DataCell(Text('${o.total.toStringAsFixed(0)} DA')),
                DataCell(_badge(o.status, o.statusColor)),
                DataCell(Text(_fmtDate(o.createdAt))),
              ])).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════ HELPERS ═══════════════════

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text[0].toUpperCase() + text.substring(1),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final Color color;
  const _StatData(this.icon, this.label, this.value, this.trend, this.color);
}
