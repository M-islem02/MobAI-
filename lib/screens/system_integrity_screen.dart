import 'package:flutter/material.dart';
import '../models/admin_data.dart';

/// Section 7.3 item 6: Ensures system integrity and data consistency.
class SystemIntegrityScreen extends StatefulWidget {
  const SystemIntegrityScreen({super.key});
  @override
  State<SystemIntegrityScreen> createState() => _SystemIntegrityScreenState();
}

class _SystemIntegrityScreenState extends State<SystemIntegrityScreen> {
  late List<SystemCheckResult> _checks;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _checks = MockWarehouseState.systemChecks;
  }

  int get _passed => _checks.where((c) => c.status == 'passed').length;
  int get _warnings => _checks.where((c) => c.status == 'warning').length;
  int get _failed => _checks.where((c) => c.status == 'failed').length;
  double get _healthScore => _checks.isEmpty ? 100 : (_passed / _checks.length * 100);

  void _runAllChecks() async {
    setState(() => _running = true);
    // Simulate check execution
    await Future.delayed(const Duration(seconds: 2));
    for (final c in _checks) {
      c.lastRun = DateTime.now();
    }
    setState(() => _running = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All integrity checks completed'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ═══ HEALTH OVERVIEW ═══
        _buildHealthOverview(),
        const SizedBox(height: 20),

        // ═══ CHECKS BY CATEGORY ═══
        _buildCategorySection('stock', 'Stock & Inventory', Icons.inventory_2_rounded),
        const SizedBox(height: 14),
        _buildCategorySection('locations', 'Locations & Warehouses', Icons.location_on_rounded),
        const SizedBox(height: 14),
        _buildCategorySection('users', 'Users & Access', Icons.people_rounded),
        const SizedBox(height: 14),
        _buildCategorySection('transactions', 'Transactions & Audit', Icons.receipt_long_rounded),
      ],
    );
  }

  Widget _buildHealthOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: LayoutBuilder(builder: (ctx, c) {
        final wide = c.maxWidth > 700;
        return Column(
          children: [
            Row(
              children: [
                const Icon(Icons.security_rounded, size: 22, color: AppColors.primaryDark),
                const SizedBox(width: 10),
                const Text('System Integrity Dashboard',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const Spacer(),
                if (_running)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                else
                  FilledButton.icon(
                    onPressed: _runAllChecks,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Run All Checks'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            wide
                ? Row(
                    children: [
                      _healthGauge(),
                      const SizedBox(width: 32),
                      Expanded(child: _statCards()),
                    ],
                  )
                : Column(
                    children: [
                      _healthGauge(),
                      const SizedBox(height: 16),
                      _statCards(),
                    ],
                  ),
          ],
        );
      }),
    );
  }

  Widget _healthGauge() {
    final healthColor = _healthScore >= 90
        ? AppColors.success
        : _healthScore >= 70
            ? AppColors.accent
            : AppColors.error;
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: _healthScore / 100,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(healthColor),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${_healthScore.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: healthColor)),
              const Text('Health', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCards() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _miniStat('${_checks.length}', 'Total Checks', Icons.checklist_rounded, AppColors.primary),
        _miniStat('$_passed', 'Passed', Icons.check_circle_rounded, AppColors.success),
        _miniStat('$_warnings', 'Warnings', Icons.warning_rounded, AppColors.accent),
        _miniStat('$_failed', 'Failed', Icons.error_rounded, AppColors.error),
      ],
    );
  }

  Widget _miniStat(String value, String label, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, String title, IconData icon) {
    final checks = _checks.where((c) => c.category == category).toList();
    final allPassed = checks.every((c) => c.status == 'passed');
    final hasFailed = checks.any((c) => c.status == 'failed');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (allPassed ? AppColors.success : hasFailed ? AppColors.error : AppColors.accent).withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (allPassed ? AppColors.success : hasFailed ? AppColors.error : AppColors.accent).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    allPassed ? 'All Passed' : hasFailed ? 'Issues Found' : 'Warnings',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: allPassed ? AppColors.success : hasFailed ? AppColors.error : AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Check items
          ...checks.map((c) => _buildCheckItem(c)),
        ],
      ),
    );
  }

  Widget _buildCheckItem(SystemCheckResult c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(c.statusIcon, size: 20, color: c.statusColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.checkName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(c.details, style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
              ],
            ),
          ),
          if (c.affectedRecords != null && c.affectedRecords! > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${c.affectedRecords} records', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c.statusColor)),
            ),
          ],
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmtTime(c.lastRun), style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
