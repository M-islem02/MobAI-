import 'package:flutter/material.dart';
import '../models/admin_data.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});
  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  late List<AuditLogEntry> _logs;
  String _actionFilter = 'all';
  String _search = '';
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _logs = MockDataGenerator.generateAuditLogs();
  }

  List<AuditLogEntry> get _filtered {
    return _logs.where((l) {
      if (_actionFilter != 'all' && l.action != _actionFilter) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return l.description.toLowerCase().contains(q) || l.userName.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildToolbar(),
          const SizedBox(height: 14),
          Expanded(child: _buildLogList()),
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
      child: Row(
        children: [
          SizedBox(
            width: 260, height: 40,
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search logs...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textLight),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true, fillColor: AppColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _actionFilter,
                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Actions')),
                  DropdownMenuItem(value: 'create', child: Text('Create')),
                  DropdownMenuItem(value: 'update', child: Text('Update')),
                  DropdownMenuItem(value: 'delete', child: Text('Delete')),
                  DropdownMenuItem(value: 'override', child: Text('Override')),
                  DropdownMenuItem(value: 'login', child: Text('Login')),
                ],
                onChanged: (v) => setState(() => _actionFilter = v!),
              ),
            ),
          ),
          const Spacer(),
          Text('${_filtered.length} entries', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    final list = _filtered;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: list.isEmpty
          ? const Center(child: Text('No logs found', style: TextStyle(color: AppColors.textLight)))
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (_, i) => _buildLogEntry(list[i]),
            ),
    );
  }

  Widget _buildLogEntry(AuditLogEntry log) {
    final isExpanded = _expandedIds.contains(log.id);
    final hasData = log.beforeData != null || log.afterData != null;

    return InkWell(
      onTap: hasData ? () => setState(() {
        if (isExpanded) {
          _expandedIds.remove(log.id);
        } else {
          _expandedIds.add(log.id);
        }
      }) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        color: isExpanded ? log.actionColor.withValues(alpha: 0.04) : Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              // Action icon
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: log.actionColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_actionIcon(log.action), size: 18, color: log.actionColor),
              ),
              const SizedBox(width: 12),
              // Main content
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(log.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.person_outline, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(log.userName, style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 12, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(_fmtDate(log.timestamp), style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
                  if (log.ipAddress != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.language, size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(log.ipAddress!, style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
                  ],
                ]),
              ])),
              // Action badge
              _actionBadge(log.action, log.actionColor),
              if (hasData) ...[
                const SizedBox(width: 8),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 18, color: AppColors.textLight),
              ],
            ]),

            // Expanded: Before/After diff
            if (isExpanded && hasData) ...[
              const SizedBox(height: 14),
              _buildDiffView(log),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiffView(AuditLogEntry log) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (log.beforeData != null)
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: const Text('BEFORE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.error)),
                ),
                const SizedBox(height: 8),
                ...log.beforeData!.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        Text('${e.key}: ', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                        Text(e.value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error, fontFamily: 'monospace')),
                      ]),
                    )),
              ]),
            ),
          if (log.beforeData != null && log.afterData != null)
            Container(
              width: 1, height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.divider,
            ),
          if (log.afterData != null)
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: const Text('AFTER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
                ),
                const SizedBox(height: 8),
                ...log.afterData!.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        Text('${e.key}: ', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                        Text(e.value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success, fontFamily: 'monospace')),
                      ]),
                    )),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _actionBadge(String action, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(action[0].toUpperCase() + action.substring(1), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'create': return Icons.add_circle_outline;
      case 'update': return Icons.edit_outlined;
      case 'delete': return Icons.delete_outline;
      case 'override': return Icons.compare_arrows_rounded;
      case 'login': return Icons.login_rounded;
      default: return Icons.info_outline;
    }
  }

  String _fmtDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
