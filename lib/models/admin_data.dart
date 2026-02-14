import 'dart:math';
import 'dart:ui';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
final _rng = Random(42);

// ═══════════════════════════════════════════════════════════════
//  DESIGN SYSTEM COLORS (§7.1)
// ═══════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();
  // Primary
  static const Color primaryDark = Color(0xFF006D84);
  static const Color primary = Color(0xFF0E93AF);
  // Semantic
  static const Color accent = Color(0xFFFAC460);   // Orange → Human Overrides
  static const Color success = Color(0xFF35BB96);   // Mint Green → Validated / Approved
  static const Color error = Color(0xFFF21919);     // Red    → Errors / Critical
  static const Color aiBlue = Color(0xFF2E8BC0);    // Blue   → AI Decisions
  static const Color archived = Color(0xFF9EAAB8);  // Grey   → Archived / Historical
  // Surfaces
  static const Color bg = Color(0xFFF6F6F6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8ECF0);
  // Text
  static const Color textDark = Color(0xFF1A2B3C);
  static const Color textMid = Color(0xFF5A6B7C);
  static const Color textLight = Color(0xFF8A9BAC);
  // Sidebar
  static const Color sidebar = Color(0xFF006D84);
  static const Color sidebarHover = Color(0xFF0E93AF);
}

// ═══════════════════════════════════════════════════════════════
//  APP USER
// ═══════════════════════════════════════════════════════════════

class AppUser {
  final String id;
  String name;
  String username;
  String email;
  String password;
  String firstName;
  String lastName;
  String role;   // admin, supervisor, employee
  String status; // active, inactive, suspended
  bool active;
  bool accountNonExpired;
  bool accountNonLocked;
  bool credentialsNonExpired;
  DateTime createdAt;
  DateTime? lastLogin;
  Color avatarColor;

  String get fullName => '$firstName $lastName'.trim();
  bool get canAuthenticate =>
      status == 'active' &&
      active &&
      accountNonExpired &&
      accountNonLocked &&
      credentialsNonExpired;

  AppUser({
    String? id,
    required this.name,
    String? username,
    required this.email,
    this.password = '123456',
    String? firstName,
    String? lastName,
    this.role = 'employee',
    this.status = 'active',
    this.active = true,
    this.accountNonExpired = true,
    this.accountNonLocked = true,
    this.credentialsNonExpired = true,
    DateTime? createdAt,
    this.lastLogin,
    Color? avatarColor,
  })  : id = id ?? _uuid.v4(),
        username = username ?? email.split('@').first,
        firstName = firstName ?? (name.trim().isEmpty ? '' : name.trim().split(' ').first),
        lastName = lastName ?? (() {
          final parts = name.trim().split(' ');
          if (parts.length <= 1) return '';
          return parts.sublist(1).join(' ');
        })(),
        createdAt = createdAt ?? DateTime.now(),
        avatarColor = avatarColor ?? _randomColor();

  static Color _randomColor() {
    const colors = [
      Color(0xFF2196F3), Color(0xFF4CAF50), Color(0xFFFF9800),
      Color(0xFF9C27B0), Color(0xFFE91E63), Color(0xFF00BCD4),
      Color(0xFF795548), Color(0xFF607D8B),
    ];
    return colors[_rng.nextInt(colors.length)];
  }
}

// ═══════════════════════════════════════════════════════════════
//  PRODUCT / INVENTORY
// ═══════════════════════════════════════════════════════════════

class Product {
  final String id;
  String sku;
  String name;
  String category;
  int quantity;
  int minStock;
  int maxStock;
  String locationLabel;
  double price;
  DateTime lastUpdated;

  String get status {
    if (quantity <= 0) return 'out-of-stock';
    if (quantity <= minStock) return 'low-stock';
    return 'in-stock';
  }

  Color get statusColor {
    switch (status) {
      case 'in-stock':
        return AppColors.success;
      case 'low-stock':
        return AppColors.accent;
      default:
        return AppColors.error;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'in-stock':
        return 'In Stock';
      case 'low-stock':
        return 'Low Stock';
      default:
        return 'Out of Stock';
    }
  }

  Product({
    String? id,
    required this.sku,
    required this.name,
    required this.category,
    this.quantity = 0,
    this.minStock = 10,
    this.maxStock = 100,
    this.locationLabel = 'A-01',
    this.price = 0,
    DateTime? lastUpdated,
  })  : id = id ?? _uuid.v4(),
        lastUpdated = lastUpdated ?? DateTime.now();
}

// ═══════════════════════════════════════════════════════════════
//  AI DECISION
// ═══════════════════════════════════════════════════════════════

class AiDecision {
  final String id;
  String action;        // reorder, relocate, alert, optimize
  String description;
  DateTime timestamp;
  String status;        // approved, overridden, pending
  double confidence;
  String userName;

  Color get statusColor {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'overridden':
        return AppColors.accent;
      default:
        return AppColors.aiBlue;
    }
  }

  AiDecision({
    String? id,
    required this.action,
    required this.description,
    DateTime? timestamp,
    this.status = 'pending',
    this.confidence = 0.85,
    this.userName = 'System',
  })  : id = id ?? _uuid.v4(),
        timestamp = timestamp ?? DateTime.now();
}

// ═══════════════════════════════════════════════════════════════
//  AUDIT LOG
// ═══════════════════════════════════════════════════════════════

class AuditLogEntry {
  final String id;
  String action;        // create, update, delete, override, login
  String description;
  DateTime timestamp;
  String userName;
  String? ipAddress;
  Map<String, String>? beforeData;
  Map<String, String>? afterData;

  Color get actionColor {
    switch (action) {
      case 'create':
        return AppColors.success;
      case 'update':
        return AppColors.aiBlue;
      case 'delete':
        return AppColors.error;
      case 'override':
        return AppColors.accent;
      default:
        return AppColors.archived;
    }
  }

  AuditLogEntry({
    String? id,
    required this.action,
    required this.description,
    DateTime? timestamp,
    required this.userName,
    this.ipAddress,
    this.beforeData,
    this.afterData,
  })  : id = id ?? _uuid.v4(),
        timestamp = timestamp ?? DateTime.now();
}

// ═══════════════════════════════════════════════════════════════
//  ORDER ENTRY (for dashboard recent orders)
// ═══════════════════════════════════════════════════════════════

class OrderEntry {
  final String id;
  String orderNumber;
  String customer;
  int items;
  double total;
  String status; // processing, shipped, delivered, cancelled
  DateTime createdAt;

  Color get statusColor {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'shipped':
        return AppColors.aiBlue;
      case 'processing':
        return AppColors.accent;
      default:
        return AppColors.error;
    }
  }

  OrderEntry({
    String? id,
    required this.orderNumber,
    required this.customer,
    this.items = 1,
    this.total = 0,
    this.status = 'processing',
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();
}

// ═══════════════════════════════════════════════════════════════
//  CHART DATA POINTS
// ═══════════════════════════════════════════════════════════════

class ChartPoint {
  final String label;
  final double value;
  final Color? color;
  const ChartPoint(this.label, this.value, [this.color]);
}

// ═══════════════════════════════════════════════════════════════
//  MOCK DATA GENERATOR
// ═══════════════════════════════════════════════════════════════

class MockDataGenerator {
  static final _r = Random(99);

  // ── Users ──
  static List<AppUser> generateUsers() {
    final now = DateTime.now();
    return [
      AppUser(name: 'Admin Principal', firstName: 'Admin', lastName: 'Principal', username: 'admin', email: 'admin@namla.dz', password: 'admin123', role: 'admin', status: 'active', active: true, accountNonExpired: true, accountNonLocked: true, credentialsNonExpired: true, lastLogin: now.subtract(const Duration(minutes: 5)), avatarColor: const Color(0xFF006D84)),
      AppUser(name: 'Karim Bensalah', firstName: 'Karim', lastName: 'Bensalah', username: 'karim.b', email: 'karim.b@namla.dz', password: 'karim123', role: 'supervisor', status: 'active', lastLogin: now.subtract(const Duration(hours: 2)), avatarColor: const Color(0xFF4CAF50)),
      AppUser(name: 'Amina Rachedi', firstName: 'Amina', lastName: 'Rachedi', username: 'amina.r', email: 'amina.r@namla.dz', password: 'amina123', role: 'supervisor', status: 'active', lastLogin: now.subtract(const Duration(hours: 6)), avatarColor: const Color(0xFFE91E63)),
      AppUser(name: 'Youcef Slimani', firstName: 'Youcef', lastName: 'Slimani', username: 'youcef.s', email: 'youcef.s@namla.dz', password: 'youcef123', role: 'employee', status: 'active', lastLogin: now.subtract(const Duration(hours: 1)), avatarColor: const Color(0xFF2196F3)),
      AppUser(name: 'Fatima Zahra', firstName: 'Fatima', lastName: 'Zahra', username: 'fatima.z', email: 'fatima.z@namla.dz', password: 'fatima123', role: 'employee', status: 'active', lastLogin: now.subtract(const Duration(days: 1)), avatarColor: const Color(0xFF9C27B0)),
      AppUser(name: 'Mohamed Aissani', firstName: 'Mohamed', lastName: 'Aissani', username: 'mohamed.a', email: 'mohamed.a@namla.dz', password: 'mohamed123', role: 'employee', status: 'inactive', active: false, lastLogin: now.subtract(const Duration(days: 14)), avatarColor: const Color(0xFF795548)),
      AppUser(name: 'Sara Belkacem', firstName: 'Sara', lastName: 'Belkacem', username: 'sara.b', email: 'sara.b@namla.dz', password: 'sara123', role: 'employee', status: 'active', lastLogin: now.subtract(const Duration(hours: 3)), avatarColor: const Color(0xFFFF9800)),
      AppUser(name: 'Ali Djeradi', firstName: 'Ali', lastName: 'Djeradi', username: 'ali.d', email: 'ali.d@namla.dz', password: 'ali123', role: 'employee', status: 'suspended', accountNonLocked: false, lastLogin: now.subtract(const Duration(days: 30)), avatarColor: const Color(0xFF607D8B)),
    ];
  }

  // ── Products ──
  static List<Product> generateProducts() {
    return [
      Product(sku: 'ELC-001', name: 'Câble H07V-U 2.5mm²', category: 'Électrique', quantity: 320, minStock: 50, maxStock: 500, locationLabel: 'A-01', price: 45.0),
      Product(sku: 'ELC-002', name: 'Disjoncteur 16A', category: 'Électrique', quantity: 85, minStock: 20, maxStock: 200, locationLabel: 'A-02', price: 890.0),
      Product(sku: 'ELC-003', name: 'Prise murale double', category: 'Électrique', quantity: 12, minStock: 30, maxStock: 300, locationLabel: 'A-03', price: 250.0),
      Product(sku: 'HDW-001', name: 'Boulon M10x60 (x100)', category: 'Quincaillerie', quantity: 450, minStock: 100, maxStock: 1000, locationLabel: 'B-01', price: 320.0),
      Product(sku: 'HDW-002', name: 'Vis autoperceuse 4.8x25', category: 'Quincaillerie', quantity: 0, minStock: 50, maxStock: 500, locationLabel: 'B-02', price: 180.0),
      Product(sku: 'SAF-001', name: 'Casque de chantier', category: 'Sécurité', quantity: 67, minStock: 15, maxStock: 100, locationLabel: 'C-01', price: 1200.0),
      Product(sku: 'SAF-002', name: 'Gants isolants CL2', category: 'Sécurité', quantity: 8, minStock: 10, maxStock: 80, locationLabel: 'C-02', price: 2500.0),
      Product(sku: 'TLS-001', name: 'Perceuse sans fil 18V', category: 'Outillage', quantity: 24, minStock: 5, maxStock: 40, locationLabel: 'D-01', price: 8500.0),
      Product(sku: 'TLS-002', name: 'Mètre laser 50m', category: 'Outillage', quantity: 31, minStock: 8, maxStock: 50, locationLabel: 'D-02', price: 4200.0),
      Product(sku: 'PKG-001', name: 'Carton 60x40x30', category: 'Emballage', quantity: 1200, minStock: 200, maxStock: 2000, locationLabel: 'E-01', price: 85.0),
      Product(sku: 'PKG-002', name: 'Film étirable 500mm', category: 'Emballage', quantity: 45, minStock: 20, maxStock: 100, locationLabel: 'E-02', price: 350.0),
      Product(sku: 'ELC-004', name: 'Tableau électrique 13M', category: 'Électrique', quantity: 18, minStock: 5, maxStock: 30, locationLabel: 'A-04', price: 3200.0),
      Product(sku: 'HDW-003', name: 'Cheville chimique M12', category: 'Quincaillerie', quantity: 95, minStock: 30, maxStock: 200, locationLabel: 'B-03', price: 550.0),
      Product(sku: 'TLS-003', name: 'Niveau laser rotatif', category: 'Outillage', quantity: 6, minStock: 3, maxStock: 15, locationLabel: 'D-03', price: 15000.0),
      Product(sku: 'SAF-003', name: 'Harnais antichute', category: 'Sécurité', quantity: 22, minStock: 10, maxStock: 50, locationLabel: 'C-03', price: 4800.0),
    ];
  }

  // ── Orders ──
  static List<OrderEntry> generateOrders() {
    final now = DateTime.now();
    return [
      OrderEntry(orderNumber: 'ORD-2401', customer: 'Sonelgaz Alger', items: 12, total: 45200, status: 'processing', createdAt: now.subtract(const Duration(hours: 1))),
      OrderEntry(orderNumber: 'ORD-2400', customer: 'COSIDER TP', items: 8, total: 28500, status: 'shipped', createdAt: now.subtract(const Duration(hours: 3))),
      OrderEntry(orderNumber: 'ORD-2399', customer: 'ETRHB Haddad', items: 25, total: 112000, status: 'delivered', createdAt: now.subtract(const Duration(hours: 8))),
      OrderEntry(orderNumber: 'ORD-2398', customer: 'Condor Electronics', items: 5, total: 18700, status: 'processing', createdAt: now.subtract(const Duration(hours: 12))),
      OrderEntry(orderNumber: 'ORD-2397', customer: 'ENIEM Tizi Ouzou', items: 15, total: 67300, status: 'shipped', createdAt: now.subtract(const Duration(days: 1))),
      OrderEntry(orderNumber: 'ORD-2396', customer: 'Groupe Cevital', items: 30, total: 185000, status: 'delivered', createdAt: now.subtract(const Duration(days: 1, hours: 6))),
      OrderEntry(orderNumber: 'ORD-2395', customer: 'SNVI Rouiba', items: 3, total: 9400, status: 'cancelled', createdAt: now.subtract(const Duration(days: 2))),
      OrderEntry(orderNumber: 'ORD-2394', customer: 'Naftal Distribution', items: 18, total: 74200, status: 'delivered', createdAt: now.subtract(const Duration(days: 2, hours: 5))),
    ];
  }

  // ── AI Decisions ──
  static List<AiDecision> generateAiDecisions() {
    final now = DateTime.now();
    return [
      AiDecision(action: 'reorder', description: 'Auto-reorder triggered for Câble H07V-U — stock below threshold', timestamp: now.subtract(const Duration(minutes: 15)), status: 'approved', confidence: 0.94, userName: 'AI Engine'),
      AiDecision(action: 'relocate', description: 'Suggest moving Disjoncteur 16A to Zone A-05 for faster picking', timestamp: now.subtract(const Duration(hours: 1)), status: 'pending', confidence: 0.87, userName: 'AI Engine'),
      AiDecision(action: 'alert', description: 'Demand spike predicted for Casque de chantier — +40% next week', timestamp: now.subtract(const Duration(hours: 2)), status: 'approved', confidence: 0.91, userName: 'AI Engine'),
      AiDecision(action: 'optimize', description: 'Route optimization: reduce picking distance by 18% on Floor 1', timestamp: now.subtract(const Duration(hours: 4)), status: 'overridden', confidence: 0.82, userName: 'Karim Bensalah'),
      AiDecision(action: 'reorder', description: 'Auto-reorder for Vis autoperceuse — zero stock detected', timestamp: now.subtract(const Duration(hours: 6)), status: 'approved', confidence: 0.98, userName: 'AI Engine'),
      AiDecision(action: 'alert', description: 'Storage utilization critical on Floor 3 — 92% capacity', timestamp: now.subtract(const Duration(hours: 8)), status: 'approved', confidence: 0.96, userName: 'AI Engine'),
      AiDecision(action: 'relocate', description: 'Consolidate slow-moving items from Zone D to Zone E', timestamp: now.subtract(const Duration(hours: 12)), status: 'overridden', confidence: 0.79, userName: 'Amina Rachedi'),
      AiDecision(action: 'optimize', description: 'Batch processing recommended for 5 pending shipments', timestamp: now.subtract(const Duration(days: 1)), status: 'approved', confidence: 0.88, userName: 'AI Engine'),
    ];
  }

  // ── Audit Logs ──
  static List<AuditLogEntry> generateAuditLogs() {
    final now = DateTime.now();
    return [
      AuditLogEntry(action: 'login', description: 'Admin logged in from Chrome/Windows', timestamp: now.subtract(const Duration(minutes: 5)), userName: 'Admin Principal', ipAddress: '192.168.1.100'),
      AuditLogEntry(action: 'update', description: 'Updated stock quantity for ELC-001', timestamp: now.subtract(const Duration(minutes: 30)), userName: 'Karim Bensalah', ipAddress: '192.168.1.105', beforeData: {'quantity': '280'}, afterData: {'quantity': '320'}),
      AuditLogEntry(action: 'override', description: 'Override AI reorder suggestion for HDW-002', timestamp: now.subtract(const Duration(hours: 1)), userName: 'Amina Rachedi', ipAddress: '192.168.1.108', beforeData: {'action': 'reorder', 'qty': '200'}, afterData: {'action': 'cancelled', 'reason': 'Supplier delay'}),
      AuditLogEntry(action: 'create', description: 'New product added: Niveau laser rotatif (TLS-003)', timestamp: now.subtract(const Duration(hours: 2)), userName: 'Admin Principal', ipAddress: '192.168.1.100'),
      AuditLogEntry(action: 'update', description: 'Zone B-03 status changed to Partial', timestamp: now.subtract(const Duration(hours: 3)), userName: 'Youcef Slimani', ipAddress: '192.168.1.112'),
      AuditLogEntry(action: 'delete', description: 'Removed expired product batch PKG-OLD-001', timestamp: now.subtract(const Duration(hours: 5)), userName: 'Admin Principal', ipAddress: '192.168.1.100', beforeData: {'sku': 'PKG-OLD-001', 'name': 'Carton ancien modèle', 'qty': '0'}),
      AuditLogEntry(action: 'create', description: 'New user created: Sara Belkacem (employee)', timestamp: now.subtract(const Duration(hours: 8)), userName: 'Admin Principal', ipAddress: '192.168.1.100'),
      AuditLogEntry(action: 'update', description: 'Warehouse Floor 2 dimensions updated to 60×35m', timestamp: now.subtract(const Duration(hours: 12)), userName: 'Admin Principal', ipAddress: '192.168.1.100', beforeData: {'width': '55', 'height': '30'}, afterData: {'width': '60', 'height': '35'}),
      AuditLogEntry(action: 'override', description: 'Override AI route optimization on Floor 1', timestamp: now.subtract(const Duration(days: 1)), userName: 'Karim Bensalah', ipAddress: '192.168.1.105'),
      AuditLogEntry(action: 'login', description: 'Manager login from mobile device', timestamp: now.subtract(const Duration(days: 1, hours: 2)), userName: 'Amina Rachedi', ipAddress: '10.0.0.45'),
      AuditLogEntry(action: 'update', description: 'User Ali Djeradi status changed to suspended', timestamp: now.subtract(const Duration(days: 2)), userName: 'Admin Principal', ipAddress: '192.168.1.100', beforeData: {'status': 'active'}, afterData: {'status': 'suspended'}),
    ];
  }

  // ── Stock Movement Time-Series (12 months) ──
  static List<ChartPoint> generateStockMovements() {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    final values = [420, 380, 510, 470, 590, 620, 580, 650, 710, 680, 740, 790];
    return List.generate(12, (i) => ChartPoint(months[i], values[i].toDouble()));
  }

  // ── Inventory Breakdown (by category) ──
  static List<ChartPoint> generateInventoryBreakdown() {
    return [
      const ChartPoint('Électrique', 435, AppColors.primary),
      const ChartPoint('Quincaillerie', 545, AppColors.aiBlue),
      const ChartPoint('Sécurité', 97, AppColors.accent),
      const ChartPoint('Outillage', 61, AppColors.success),
      const ChartPoint('Emballage', 1245, AppColors.archived),
    ];
  }

  // ── Dashboard metrics ──
  static Map<String, dynamic> dashboardMetrics() {
    return {
      'totalStock': 2383,
      'activeOrders': 4,
      'overrides': 3,
      'aiAccuracy': 91.2,
      'systemHealth': 98.5,
    };
  }
}

class MockAuthService {
  static final List<AppUser> users = MockDataGenerator.generateUsers();

  static AppUser? authenticate(String identifier, String password) {
    final input = identifier.trim().toLowerCase();
    for (final u in users) {
      final emailMatch = u.email.toLowerCase() == input;
      final usernameMatch = u.username.toLowerCase() == input;
      if ((emailMatch || usernameMatch) && u.password == password) {
        return u;
      }
    }
    return null;
  }
}
