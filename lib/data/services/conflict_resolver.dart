import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Conflict types
enum ConflictType {
  habit,
  habitLog,
  userProgress,
  achievement,
  plant,
}

/// Conflict resolution options
enum ConflictResolution {
  keepLocal,
  keepCloud,
  merge,
}

/// Conflict data structure
class ConflictData {
  final String id;
  final ConflictType type;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> cloudData;
  final DateTime localTimestamp;
  final DateTime cloudTimestamp;
  final List<String> differences;
  
  ConflictData({
    required this.id,
    required this.type,
    required this.localData,
    required this.cloudData,
    required this.localTimestamp,
    required this.cloudTimestamp,
    required this.differences,
  });
}

/// Conflict resolver service
class ConflictResolver {
  final List<ConflictData> _conflicts = [];
  final StreamController<List<ConflictData>> _conflictsController = 
      StreamController<List<ConflictData>>.broadcast();
  
  /// Get conflicts stream
  Stream<List<ConflictData>> get conflictsStream => _conflictsController.stream;
  
  /// Get current conflicts
  List<ConflictData> get conflicts => List.unmodifiable(_conflicts);
  
  /// Check for conflicts between local and cloud data
  Future<List<ConflictData>> detectConflicts({
    required List<Map<String, dynamic>> localData,
    required List<Map<String, dynamic>> cloudData,
    required ConflictType type,
  }) async {
    final conflicts = <ConflictData>[];
    
    for (final localItem in localData) {
      final localId = localItem['id'] as String?;
      if (localId == null) continue;
      
      // Find corresponding cloud item
      final cloudItem = cloudData.firstWhere(
        (item) => item['id'] == localId,
        orElse: () => {},
      );
      
      if (cloudItem.isEmpty) continue;
      
      // Check for conflicts
      final conflict = await _checkForConflict(
        id: localId,
        type: type,
        localData: localItem,
        cloudData: cloudItem,
      );
      
      if (conflict != null) {
        conflicts.add(conflict);
      }
    }
    
    _conflicts.addAll(conflicts);
    _conflictsController.add(_conflicts);
    
    return conflicts;
  }
  
  /// Check for specific conflict
  Future<ConflictData?> _checkForConflict({
    required String id,
    required ConflictType type,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> cloudData,
  }) async {
    // Compare timestamps
    final localTimestamp = _parseTimestamp(localData['updatedAt']);
    final cloudTimestamp = _parseTimestamp(cloudData['updatedAt']);
    
    if (localTimestamp == null || cloudTimestamp == null) {
      return null; // No timestamps to compare
    }
    
    // If timestamps are the same, no conflict
    if (localTimestamp.isAtSameMomentAs(cloudTimestamp)) {
      return null;
    }
    
    // Find differences
    final differences = _findDifferences(localData, cloudData);
    
    if (differences.isEmpty) {
      return null; // No actual differences
    }
    
    return ConflictData(
      id: id,
      type: type,
      localData: localData,
      cloudData: cloudData,
      localTimestamp: localTimestamp,
      cloudTimestamp: cloudTimestamp,
      differences: differences,
    );
  }
  
  /// Find differences between two data maps
  List<String> _findDifferences(
    Map<String, dynamic> localData,
    Map<String, dynamic> cloudData,
  ) {
    final differences = <String>[];
    final allKeys = {...localData.keys, ...cloudData.keys};
    
    for (final key in allKeys) {
      final localValue = localData[key];
      final cloudValue = cloudData[key];
      
      if (localValue != cloudValue) {
        differences.add('$key: local="${localValue}" vs cloud="${cloudValue}"');
      }
    }
    
    return differences;
  }
  
  /// Parse timestamp from various formats
  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    }
    if (timestamp is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }
  
  /// Resolve conflict with user choice
  Future<Map<String, dynamic>> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
  }) async {
    final conflict = _conflicts.firstWhere(
      (c) => c.id == conflictId,
      orElse: () => throw Exception('Conflict not found'),
    );
    
    Map<String, dynamic> resolvedData;
    
    switch (resolution) {
      case ConflictResolution.keepLocal:
        resolvedData = conflict.localData;
        break;
      case ConflictResolution.keepCloud:
        resolvedData = conflict.cloudData;
        break;
      case ConflictResolution.merge:
        resolvedData = await _mergeData(conflict);
        break;
    }
    
    // Remove resolved conflict
    _conflicts.removeWhere((c) => c.id == conflictId);
    _conflictsController.add(_conflicts);
    
    return resolvedData;
  }
  
  /// Merge data from both sources
  Future<Map<String, dynamic>> _mergeData(ConflictData conflict) async {
    final merged = <String, dynamic>{};
    final allKeys = {...conflict.localData.keys, ...conflict.cloudData.keys};
    
    for (final key in allKeys) {
      final localValue = conflict.localData[key];
      final cloudValue = conflict.cloudData[key];
      
      if (localValue == cloudValue) {
        merged[key] = localValue;
      } else {
        // Use the more recent value based on timestamp
        if (conflict.localTimestamp.isAfter(conflict.cloudTimestamp)) {
          merged[key] = localValue;
        } else {
          merged[key] = cloudValue;
        }
      }
    }
    
    // Update timestamp to now
    merged['updatedAt'] = DateTime.now().toIso8601String();
    
    return merged;
  }
  
  /// Clear all conflicts
  void clearConflicts() {
    _conflicts.clear();
    _conflictsController.add(_conflicts);
  }
  
  /// Get conflict by ID
  ConflictData? getConflictById(String id) {
    try {
      return _conflicts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get conflicts by type
  List<ConflictData> getConflictsByType(ConflictType type) {
    return _conflicts.where((c) => c.type == type).toList();
  }
  
  /// Get conflict summary
  Map<String, dynamic> getConflictSummary() {
    final summary = <String, int>{};
    
    for (final conflict in _conflicts) {
      final typeKey = conflict.type.toString().split('.').last;
      summary[typeKey] = (summary[typeKey] ?? 0) + 1;
    }
    
    return {
      'totalConflicts': _conflicts.length,
      'byType': summary,
      'hasConflicts': _conflicts.isNotEmpty,
    };
  }
  
  /// Dispose resources
  void dispose() {
    _conflictsController.close();
  }
}

/// Riverpod provider for ConflictResolver
final conflictResolverProvider = Provider<ConflictResolver>((ref) {
  return ConflictResolver();
});

/// Riverpod provider for conflicts
final conflictsProvider = StreamProvider<List<ConflictData>>((ref) {
  final resolver = ref.watch(conflictResolverProvider);
  return resolver.conflictsStream;
});

/// Riverpod provider for conflict summary
final conflictSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final resolver = ref.watch(conflictResolverProvider);
  return resolver.getConflictSummary();
});
