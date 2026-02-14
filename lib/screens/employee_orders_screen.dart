import 'package:flutter/material.dart';
import '../models/warehouse_data.dart';
import 'order_detail_screen.dart';

class EmployeeOrdersScreen extends StatefulWidget {
  final Employee employee;
  final List<Employee> allEmployees;
  final List<WarehouseTask> tasks;

  const EmployeeOrdersScreen({
    super.key,
    required this.employee,
    required this.allEmployees,
    required this.tasks,
  });

  @override
  State<EmployeeOrdersScreen> createState() => _EmployeeOrdersScreenState();
}

class _EmployeeOrdersScreenState extends State<EmployeeOrdersScreen> {
  List<WarehouseTask> get _myTasks => widget.tasks
      .where((t) => t.assignedEmployeeId == widget.employee.id)
      .toList();

  double get _progress {
    final tasks = _myTasks;
    if (tasks.isEmpty) return 0;
    final completed =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    return completed / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (_progress * 100).toInt();
    final myTasks = _myTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDEF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Online',
                            style: TextStyle(
                                color: Color(0xFF65C888),
                                fontWeight: FontWeight.w600,
                                fontSize: 11)),
                        SizedBox(width: 6),
                        Icon(Icons.circle,
                            size: 8, color: Color(0xFF65C888)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        size: 24, color: Color(0xFF111111)),
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/login'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Orders progresse',
                  style: TextStyle(
                    fontSize: 34 / 2,
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '$progressPercent%',
                    style: const TextStyle(
                      color: Color(0xFF4B5666),
                      fontWeight: FontWeight.w700,
                      fontSize: 31 / 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFCDCDD1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF5CC18A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: myTasks.isEmpty
                    ? Center(
                        child: Text(
                          'No orders',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: myTasks.length,
                        itemBuilder: (context, index) =>
                            _buildOrderCard(myTasks[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════ ORDER CARD ═══════════════════

  Widget _buildOrderCard(WarehouseTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB9C5D0), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(
                task: task,
                employee: widget.employee,
                allEmployees: widget.allEmployees,
                allTasks: widget.tasks,
              ),
            ),
          );
          if (mounted) setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_cart_outlined,
                    color: Color(0xFF0A88A8), size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.orderCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF153248),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      task.productName,
                      style: const TextStyle(
                          fontSize: 14 / 1.1, color: Color(0xFF4D4D4D)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8EAED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.north_east_rounded,
                    color: Color(0xFF96D8E8), size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
