import 'package:flutter/material.dart';

import '../models/admin_data.dart';
import '../models/mobai_models.dart';

class AiValidationScreen extends StatefulWidget {
  const AiValidationScreen({super.key});

  @override
  State<AiValidationScreen> createState() => _AiValidationScreenState();
}

class _AiValidationScreenState extends State<AiValidationScreen> {
  late final List<ValidationTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = MobAiMock.generateTasks();
  }

  void _validateTask(ValidationTask task) {
    setState(() => task.status = TaskStatus.validated);
  }

  Future<void> _overrideTask(ValidationTask task) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Override AI Decision'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Justification (required)',
            hintText: 'Explain why the AI output is overridden...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Confirm Override'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (reason == null || reason.isEmpty) return;

    setState(() {
      task.status = TaskStatus.failed;
      task.overrideJustification = reason;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Validation & Overrides',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: 6),
        const Text(
          'Supervisors/Admin can validate or override with mandatory justification (FR-5, FR-7, FR-8).',
          style: TextStyle(color: AppColors.textMid),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${task.orderRef} • ${MobAiMock.operationLabel(task.operation)}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: task.statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.statusLabel,
                              style: TextStyle(color: task.statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('SKU: ${task.sku}  •  Qty: ${task.quantity}'),
                      Text('Route: ${task.fromLocation} → ${task.toLocation}'),
                      Text('AI confidence: ${(task.confidence * 100).toStringAsFixed(1)}%'),
                      if (task.overrideJustification != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Override reason: ${task.overrideJustification}',
                          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                        )
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: task.status == TaskStatus.validated ? null : () => _validateTask(task),
                            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Validate', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _overrideTask(task),
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent),
                            icon: const Icon(Icons.edit_note),
                            label: const Text('Override'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
