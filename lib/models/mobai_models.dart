import 'package:flutter/material.dart';

import 'admin_data.dart';

enum UserRole { admin, supervisor, employee }

enum OperationType { receipt, transfer, preparation, picking, delivery }

enum TaskStatus { pending, inProgress, validated, failed }

class ValidationTask {
  final String id;
  final String orderRef;
  final OperationType operation;
  final String sku;
  final int quantity;
  final String fromLocation;
  final String toLocation;
  TaskStatus status;
  final bool aiSuggested;
  final double confidence;
  String? overrideJustification;
  final DateTime createdAt;

  ValidationTask({
    required this.id,
    required this.orderRef,
    required this.operation,
    required this.sku,
    required this.quantity,
    required this.fromLocation,
    required this.toLocation,
    this.status = TaskStatus.pending,
    this.aiSuggested = true,
    this.confidence = 0.9,
    this.overrideJustification,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get statusColor {
    switch (status) {
      case TaskStatus.validated:
        return AppColors.success;
      case TaskStatus.failed:
        return AppColors.error;
      case TaskStatus.inProgress:
        return AppColors.aiBlue;
      case TaskStatus.pending:
        return AppColors.accent;
    }
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.validated:
        return 'Validated';
      case TaskStatus.failed:
        return 'Failed';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.pending:
        return 'Pending';
    }
  }
}

class MobAiMock {
  static List<ValidationTask> generateTasks() {
    return [
      ValidationTask(
        id: 't-1',
        orderRef: 'CMD-2026-0101',
        operation: OperationType.receipt,
        sku: 'SKU-31334',
        quantity: 120,
        fromLocation: 'SUPPLIER',
        toLocation: 'B7-N1-C7',
        status: TaskStatus.validated,
        confidence: 0.94,
      ),
      ValidationTask(
        id: 't-2',
        orderRef: 'TRF-2026-0101',
        operation: OperationType.transfer,
        sku: 'SKU-31335',
        quantity: 60,
        fromLocation: 'RECEIVING',
        toLocation: 'B7-N2-C3',
        status: TaskStatus.pending,
        confidence: 0.82,
      ),
      ValidationTask(
        id: 't-3',
        orderRef: 'PREP-2026-0220',
        operation: OperationType.preparation,
        sku: 'SKU-31336',
        quantity: 70,
        fromLocation: 'B7-N1-C2',
        toLocation: 'B7-0A-02-01',
        status: TaskStatus.pending,
        confidence: 0.78,
      ),
      ValidationTask(
        id: 't-4',
        orderRef: 'PICK-2026-0220',
        operation: OperationType.picking,
        sku: 'SKU-31337',
        quantity: 30,
        fromLocation: 'B7-N3-D8',
        toLocation: 'B7-0B-01-01',
        status: TaskStatus.inProgress,
        confidence: 0.88,
      ),
      ValidationTask(
        id: 't-5',
        orderRef: 'DLV-2026-0220',
        operation: OperationType.delivery,
        sku: 'SKU-31338',
        quantity: 30,
        fromLocation: 'B7-0B-01-01',
        toLocation: 'EXPEDITION',
        status: TaskStatus.validated,
        confidence: 0.96,
      ),
    ];
  }

  static String operationLabel(OperationType op) {
    switch (op) {
      case OperationType.receipt:
        return 'Receipt';
      case OperationType.transfer:
        return 'Transfer';
      case OperationType.preparation:
        return 'Preparation';
      case OperationType.picking:
        return 'Picking';
      case OperationType.delivery:
        return 'Delivery';
    }
  }
}
