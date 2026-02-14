import 'dart:math';
import '../models/warehouse_data.dart';

/// A point along the navigation path (in meters)
class PathPoint {
  final double x;
  final double y;
  const PathPoint(this.x, this.y);
}

/// Result of a single-floor path query
class NavigationResult {
  final List<PathPoint> path;
  final StorageZone targetZone;
  final PathPoint entryPoint;
  final double totalDistanceM;

  NavigationResult({
    required this.path,
    required this.targetZone,
    required this.entryPoint,
    required this.totalDistanceM,
  });
}

/// One segment of a cross-floor journey
class FloorPathSegment {
  final int floorNumber;
  final String floorName;
  final List<PathPoint> path; // empty for elevator transition segments
  final double distanceM;
  final String instruction;
  final bool isElevatorTransition;

  FloorPathSegment({
    required this.floorNumber,
    required this.floorName,
    required this.path,
    required this.distanceM,
    required this.instruction,
    this.isElevatorTransition = false,
  });
}

/// Full cross-floor navigation result
class CrossFloorResult {
  final List<FloorPathSegment> segments;
  final StorageZone targetZone;
  final int sourceFloor;
  final int targetFloor;
  final double totalDistanceM;

  CrossFloorResult({
    required this.segments,
    required this.targetZone,
    required this.sourceFloor,
    required this.targetFloor,
    required this.totalDistanceM,
  });

  bool get isCrossFloor => sourceFloor != targetFloor;
}

/// Pathfinding service with A* and cross-floor support
class PathfindingService {
  // ════════════════ CROSS-FLOOR PATHFINDING ════════════════

  /// Find a complete path across floors (source -> elevator -> target floor -> zone).
  static CrossFloorResult? findCrossFloorPath(
    List<WarehouseFloor> allFloors,
    int sourceFloorNumber,
    StorageZone targetZone,
    int targetFloorNumber,
  ) {
    final sourceFloor =
        allFloors.firstWhere((f) => f.floorNumber == sourceFloorNumber);
    final targetFloor =
        allFloors.firstWhere((f) => f.floorNumber == targetFloorNumber);
    final segments = <FloorPathSegment>[];

    if (sourceFloorNumber == targetFloorNumber) {
      // ── Same floor ──
      final result = findPath(targetFloor, targetZone);
      if (result == null) return null;
      segments.add(FloorPathSegment(
        floorNumber: targetFloorNumber,
        floorName: targetFloor.name,
        path: result.path,
        distanceM: result.totalDistanceM,
        instruction: 'Allez a ${targetZone.label}',
      ));
    } else {
      // ── Cross-floor ──
      // 1) Find elevator on source floor
      final srcElevator = _findBestElevator(sourceFloor);
      if (srcElevator == null) return null;

      // 2) Path on source floor → elevator
      final toElevator = findPath(sourceFloor, srcElevator);
      if (toElevator != null && toElevator.path.length > 1) {
        segments.add(FloorPathSegment(
          floorNumber: sourceFloorNumber,
          floorName: sourceFloor.name,
          path: toElevator.path,
          distanceM: toElevator.totalDistanceM,
          instruction: '🚶 Allez au ${srcElevator.label} (${sourceFloor.shortName})',
        ));
      }

      // 3) Elevator transition (visual indicator, no path)
      final direction =
          targetFloorNumber > sourceFloorNumber ? 'Montez' : 'Descendez';
      segments.add(FloorPathSegment(
        floorNumber: -1,
        floorName: '',
        path: [],
        distanceM: 0,
        instruction:
            '🛗 $direction au ${WarehouseDataGenerator.floorName(targetFloorNumber)}',
        isElevatorTransition: true,
      ));

      // 4) Path on target floor from elevator → zone
      final fromElevator = findPath(targetFloor, targetZone);
      if (fromElevator != null) {
        segments.add(FloorPathSegment(
          floorNumber: targetFloorNumber,
          floorName: targetFloor.name,
          path: fromElevator.path,
          distanceM: fromElevator.totalDistanceM,
          instruction: 'Allez a ${targetZone.label} (${targetFloor.shortName})',
        ));
      }
    }

    final totalDist =
        segments.fold<double>(0, (sum, s) => sum + s.distanceM);

    return CrossFloorResult(
      segments: segments,
      targetZone: targetZone,
      sourceFloor: sourceFloorNumber,
      targetFloor: targetFloorNumber,
      totalDistanceM: totalDist,
    );
  }

  /// Find the best elevator/monte-charge on the floor
  static StorageZone? _findBestElevator(WarehouseFloor floor) {
    final elevators = floor.zones
        .where((z) =>
            z.type == ZoneType.elevator ||
            z.type == ZoneType.freightLift ||
            z.type == ZoneType.freightElevator)
        .toList();
    if (elevators.isEmpty) return null;
    // Prefer monte-charge (larger, for goods)
    return elevators.firstWhere(
        (e) => e.type == ZoneType.freightLift || e.type == ZoneType.freightElevator,
        orElse: () => elevators.first);
  }

  // ════════════════ SINGLE-FLOOR PATHFINDING ════════════════

  /// Find a walkable path from the nearest entry to [target] on one floor.
  static NavigationResult? findPath(WarehouseFloor floor, StorageZone target) {
    // 1. Collect entry points (elevators)
    final entryPoints = <PathPoint>[];
    for (var zone in floor.zones) {
      if (zone.type == ZoneType.elevator ||
          zone.type == ZoneType.freightLift ||
          zone.type == ZoneType.freightElevator) {
        entryPoints.add(PathPoint(
          zone.x + zone.widthM / 2,
          zone.y + zone.heightM,
        ));
      }
    }
    if (entryPoints.isEmpty) {
      entryPoints.add(const PathPoint(0, 15));
    }

    // 2. Target centre
    final targetCenter = PathPoint(
      target.x + target.widthM / 2,
      target.y + target.heightM / 2,
    );

    // 3. Pick closest entry
    PathPoint bestEntry = entryPoints.first;
    double bestDist = double.infinity;
    for (var entry in entryPoints) {
      final d = _dist(entry, targetCenter);
      if (d < bestDist) {
        bestDist = d;
        bestEntry = entry;
      }
    }

    // 4. Build blocked grid (1m cells)
    final int gridW = floor.totalWidthM.toInt();
    final int gridH = floor.totalHeightM.toInt();
    final blocked = List.generate(gridH, (_) => List.filled(gridW, false));

    for (var zone in floor.zones) {
      if (zone.id == target.id) continue;
      if (zone.type == ZoneType.aisle) continue;
      if (zone.type == ZoneType.elevator ||
          zone.type == ZoneType.freightLift ||
          zone.type == ZoneType.freightElevator) continue;

      final int x1 = zone.x.floor().clamp(0, gridW - 1);
      final int y1 = zone.y.floor().clamp(0, gridH - 1);
      final int x2 = (zone.x + zone.widthM).ceil().clamp(0, gridW);
      final int y2 = (zone.y + zone.heightM).ceil().clamp(0, gridH);

      for (int y = y1; y < y2; y++) {
        for (int x = x1; x < x2; x++) {
          if (x >= 0 && x < gridW && y >= 0 && y < gridH) {
            blocked[y][x] = true;
          }
        }
      }
    }

    // 5. A*
    final int sx = bestEntry.x.round().clamp(0, gridW - 1);
    final int sy = bestEntry.y.round().clamp(0, gridH - 1);
    final int ex = targetCenter.x.round().clamp(0, gridW - 1);
    final int ey = targetCenter.y.round().clamp(0, gridH - 1);
    blocked[sy][sx] = false;
    blocked[ey][ex] = false;

    final rawPath = _aStar(blocked, sx, sy, ex, ey, gridW, gridH);
    if (rawPath == null) return null;

    // 6. Smooth & compute distance
    final smoothed = _smoothPath(rawPath);
    double totalDist = 0;
    for (int i = 1; i < smoothed.length; i++) {
      totalDist += _dist(smoothed[i - 1], smoothed[i]);
    }

    return NavigationResult(
      path: smoothed,
      targetZone: target,
      entryPoint: bestEntry,
      totalDistanceM: totalDist,
    );
  }

  // ════════════════ A* CORE ════════════════

  static List<PathPoint>? _aStar(
    List<List<bool>> blocked,
    int sx, int sy, int ex, int ey,
    int w, int h,
  ) {
    int key(int x, int y) => y * w + x;
    double heuristic(int x, int y) =>
        sqrt(pow(x - ex, 2) + pow(y - ey, 2).toDouble());

    final gScore = <int, double>{};
    final fScore = <int, double>{};
    final cameFrom = <int, int>{};
    final closed = <int>{};
    final open = <_Node>[];

    final sk = key(sx, sy);
    gScore[sk] = 0;
    fScore[sk] = heuristic(sx, sy);
    open.add(_Node(sx, sy, fScore[sk]!));

    const dirs = [
      [0, -1], [0, 1], [-1, 0], [1, 0],
      [-1, -1], [-1, 1], [1, -1], [1, 1],
    ];
    const dirCosts = [1.0, 1.0, 1.0, 1.0, 1.414, 1.414, 1.414, 1.414];

    int iterations = 0;
    final maxIter = w * h * 4;

    while (open.isNotEmpty && iterations < maxIter) {
      iterations++;
      open.sort((a, b) => a.f.compareTo(b.f));
      final current = open.removeAt(0);
      final ck = key(current.x, current.y);

      if (current.x == ex && current.y == ey) {
        final result = <PathPoint>[];
        var k = ck;
        result.add(PathPoint(current.x.toDouble(), current.y.toDouble()));
        while (cameFrom.containsKey(k)) {
          k = cameFrom[k]!;
          result.add(PathPoint((k % w).toDouble(), (k ~/ w).toDouble()));
        }
        return result.reversed.toList();
      }

      closed.add(ck);

      for (int d = 0; d < dirs.length; d++) {
        final nx = current.x + dirs[d][0];
        final ny = current.y + dirs[d][1];
        if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
        if (blocked[ny][nx]) continue;
        if (d >= 4) {
          if (blocked[current.y][nx] || blocked[ny][current.x]) continue;
        }

        final nk = key(nx, ny);
        if (closed.contains(nk)) continue;

        final tentG = (gScore[ck] ?? double.infinity) + dirCosts[d];
        if (tentG < (gScore[nk] ?? double.infinity)) {
          cameFrom[nk] = ck;
          gScore[nk] = tentG;
          fScore[nk] = tentG + heuristic(nx, ny);
          open.add(_Node(nx, ny, fScore[nk]!));
        }
      }
    }
    return null;
  }

  // ════════════════ HELPERS ════════════════

  static double _dist(PathPoint a, PathPoint b) =>
      sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));

  static List<PathPoint> _smoothPath(List<PathPoint> path) {
    if (path.length <= 2) return path;
    final result = <PathPoint>[path.first];
    for (int i = 1; i < path.length - 1; i++) {
      final prev = result.last;
      final curr = path[i];
      final next = path[i + 1];
      final dx1 = (curr.x - prev.x).sign;
      final dy1 = (curr.y - prev.y).sign;
      final dx2 = (next.x - curr.x).sign;
      final dy2 = (next.y - curr.y).sign;
      if (dx1 != dx2 || dy1 != dy2) result.add(curr);
    }
    result.add(path.last);
    return result;
  }
}

class _Node {
  final int x, y;
  final double f;
  _Node(this.x, this.y, this.f);
}
