import 'package:flutter/material.dart';
import '../models/warehouse_data.dart';
import 'warehouse_home_page.dart';

class OrderDetailScreen extends StatefulWidget {
  final WarehouseTask task;
  final Employee employee;
  final List<Employee> allEmployees;
  final List<WarehouseTask> allTasks;

  const OrderDetailScreen({
    super.key,
    required this.task,
    required this.employee,
    required this.allEmployees,
    required this.allTasks,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Auto-start the task when opened
    if (widget.task.status == TaskStatus.pending) {
      widget.task.status = TaskStatus.inProgress;
      widget.task.startedAt = DateTime.now();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleScan() async {
    setState(() => _isScanning = true);

    // Simulate scanning delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Start task and open map path
    if (widget.task.status == TaskStatus.pending) {
      widget.task.status = TaskStatus.inProgress;
      widget.task.startedAt = DateTime.now();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WarehouseHomePage(
            currentEmployee: widget.employee,
            allEmployees: widget.allEmployees,
            sharedTasks: widget.allTasks,
            initialTaskId: widget.task.id,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isCompleted = task.status == TaskStatus.completed;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDEF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF111111), size: 24),
                  ),
                  const Text(
                    'Etat de recu',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w700,
                      fontSize: 33 / 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Order ID',
                          task.orderCode,
                          trailing: const Text(
                            'Copy',
                            style: TextStyle(
                              color: Color(0xFFFF5F3A),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _buildInfoRow('Order Time', _formatDate(task.createdAt)),
                        _buildInfoRow('Poyment Time', _formatDate(task.startedAt)),
                        _buildInfoRow('Ship Time', _formatDate(task.startedAt)),
                        _buildInfoRow('Completed Time', _formatDate(task.completedAt)),
                        const SizedBox(height: 16),
                        Container(
                          height: 330,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDEF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!isCompleted)
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              onPressed: _isScanning ? null : _handleScan,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1AA1C0),
                                disabledBackgroundColor:
                                    const Color(0xFF1AA1C0).withValues(alpha: 0.7),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _isScanning ? 'Scanning...' : 'Scan',
                                style: const TextStyle(
                                  fontSize: 31 / 2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════ HELPERS ═══════════════════

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF516173),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF556678),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }
}
