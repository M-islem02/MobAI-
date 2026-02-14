import 'package:flutter/material.dart';
import '../models/admin_data.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late List<AppUser> _users;
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _users = MockAuthService.users;
  }

  List<AppUser> get _filtered {
    return _users.where((u) {
      if (_roleFilter != 'all' && u.role != _roleFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.username.toLowerCase().contains(q);
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
          // ═══ TOOLBAR ═══
          _buildToolbar(),
          const SizedBox(height: 16),
          // ═══ TABLE ═══
          Expanded(child: _buildTable()),
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
            width: 260,
            height: 40,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textLight),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: AppColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _roleFilter,
                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Roles')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                  DropdownMenuItem(value: 'employee', child: Text('Employee')),
                ],
                onChanged: (v) => setState(() => _roleFilter = v!),
              ),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _showUserDialog(null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add User', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final list = _filtered;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: list.isEmpty
          ? const Center(child: Text('No users found', style: TextStyle(color: AppColors.textLight)))
          : SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  headingRowHeight: 48,
                  dataRowMinHeight: 50,
                  dataRowMaxHeight: 56,
                  columnSpacing: 20,
                  headingTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMid),
                  dataTextStyle: const TextStyle(fontSize: 13, color: AppColors.textDark),
                  columns: const [
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Last Login')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: list.map((u) => DataRow(cells: [
                    DataCell(Row(children: [
                      CircleAvatar(radius: 16, backgroundColor: u.avatarColor, child: Text(u.name[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 10),
                      Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ])),
                    DataCell(Text(u.username)),
                    DataCell(Text(u.email)),
                    DataCell(_roleBadge(u.role)),
                    DataCell(_statusBadge(u.status)),
                    DataCell(Text(u.lastLogin != null ? _fmtDate(u.lastLogin!) : '—', style: const TextStyle(fontSize: 12, color: AppColors.textMid))),
                    DataCell(Row(children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMid), onPressed: () => _showUserDialog(u)),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: () => _confirmDelete(u)),
                    ])),
                  ])).toList(),
                ),
              ),
            ),
    );
  }

  Widget _roleBadge(String role) {
    final color = role == 'admin'
        ? AppColors.primaryDark
        : role == 'supervisor'
            ? AppColors.aiBlue
            : role == 'employee'
                ? AppColors.success
                : AppColors.archived;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(role[0].toUpperCase() + role.substring(1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'active' ? AppColors.success : status == 'suspended' ? AppColors.error : AppColors.archived;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(status[0].toUpperCase() + status.substring(1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  // ═══════════════════ CREATE / EDIT DIALOG ═══════════════════

  void _showUserDialog(AppUser? existing) {
    final firstNameCtrl = TextEditingController(text: existing?.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: existing?.lastName ?? '');
    final usernameCtrl = TextEditingController(text: existing?.username ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final passwordCtrl = TextEditingController(text: existing?.password ?? '');
    String role = existing?.role ?? 'employee';
    bool active = existing?.active ?? true;
    bool accountNonExpired = existing?.accountNonExpired ?? true;
    bool accountNonLocked = existing?.accountNonLocked ?? true;
    bool credentialsNonExpired = existing?.credentialsNonExpired ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Icon(existing == null ? Icons.person_add : Icons.edit, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(existing == null ? 'New User' : 'Edit User'),
          ]),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: firstNameCtrl, decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.person_outline)))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: lastNameCtrl, decoration: const InputDecoration(labelText: 'Last Name'))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email_outlined))),
                const SizedBox(height: 12),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 12),
                TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge_outlined)),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                    DropdownMenuItem(value: 'employee', child: Text('Employee')),
                  ],
                  onChanged: (v) => setDialogState(() => role = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setDialogState(() => active = v),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Account Non Expired'),
                  value: accountNonExpired,
                  onChanged: (v) => setDialogState(() => accountNonExpired = v),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Account Non Locked'),
                  value: accountNonLocked,
                  onChanged: (v) => setDialogState(() => accountNonLocked = v),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Credentials Non Expired'),
                  value: credentialsNonExpired,
                  onChanged: (v) => setDialogState(() => credentialsNonExpired = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (firstNameCtrl.text.isEmpty || usernameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) return;

                final fullName = '${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}'.trim();
                final status = !active ? 'inactive' : (!accountNonLocked ? 'suspended' : 'active');

                if (existing != null) {
                  existing.firstName = firstNameCtrl.text.trim();
                  existing.lastName = lastNameCtrl.text.trim();
                  existing.name = fullName;
                  existing.username = usernameCtrl.text.trim();
                  existing.email = emailCtrl.text;
                  existing.password = passwordCtrl.text;
                  existing.role = role;
                  existing.status = status;
                  existing.active = active;
                  existing.accountNonExpired = accountNonExpired;
                  existing.accountNonLocked = accountNonLocked;
                  existing.credentialsNonExpired = credentialsNonExpired;
                } else {
                  _users.add(
                    AppUser(
                      name: fullName,
                      firstName: firstNameCtrl.text.trim(),
                      lastName: lastNameCtrl.text.trim(),
                      username: usernameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      password: passwordCtrl.text,
                      role: role,
                      status: status,
                      active: active,
                      accountNonExpired: accountNonExpired,
                      accountNonLocked: accountNonLocked,
                      credentialsNonExpired: credentialsNonExpired,
                    ),
                  );
                }
                Navigator.pop(ctx);
                setState(() {});
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(existing == null ? 'Create' : 'Save'),
            ),
          ],
        );
      }),
    );
  }

  void _confirmDelete(AppUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: AppColors.error), SizedBox(width: 8), Text('Delete User?')]),
        content: Text('Remove "${user.name}" permanently? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _users.remove(user));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
