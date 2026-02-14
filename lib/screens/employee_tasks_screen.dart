import 'package:flutter/material.dart';

import '../models/admin_data.dart';
import '../models/mobai_models.dart';

class EmployeeTasksScreen extends StatefulWidget {
  const EmployeeTasksScreen({super.key});

  @override
  State<EmployeeTasksScreen> createState() => _EmployeeTasksScreenState();
}

class _EmployeeTasksScreenState extends State<EmployeeTasksScreen> {
  late final List<ValidationTask> _allTasks;

  @override
  void initState() {
    super.initState();
    _allTasks = MobAiMock.generateTasks();
  }

  @override
  Widget build(BuildContext context) {
    final validatedTasks = _allTasks
        .where((task) => task.status == TaskStatus.validated)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Employee Tasks'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
            icon: const Icon(Icons.logout, color: AppColors.textMid),
            label: const Text('Logout', style: TextStyle(color: AppColors.textMid)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoBanner(),
          const SizedBox(height: 12),
          ...validatedTasks.map(_taskTile),
          if (validatedTasks.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No validated tasks available.'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: AppColors.success),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Employee view only shows validated tasks (FR-6).',
              style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskTile(ValidationTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text('${task.orderRef} • ${MobAiMock.operationLabel(task.operation)}'),
        subtitle: Text('${task.sku} • Qty ${task.quantity}\n${task.fromLocation} → ${task.toLocation}'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: task.statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            task.statusLabel,
            style: TextStyle(color: task.statusColor, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
