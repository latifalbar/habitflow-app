import 'package:json_annotation/json_annotation.dart';

part 'coins_transaction.g.dart';

enum CoinsTransactionType {
  earned,
  spent,
}

class CoinsTransaction {
  final String id;
  final int amount;
  final CoinsTransactionType type;
  final String reason;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const CoinsTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.reason,
    required this.timestamp,
    this.metadata = const {},
  });

  factory CoinsTransaction.fromJson(Map<String, dynamic> json) =>
      _$CoinsTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$CoinsTransactionToJson(this);

  CoinsTransaction copyWith({
    String? id,
    int? amount,
    CoinsTransactionType? type,
    String? reason,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return CoinsTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoinsTransaction &&
        other.id == id &&
        other.amount == amount &&
        other.type == type &&
        other.reason == reason &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(id, amount, type, reason, timestamp);
  }

  @override
  String toString() {
    return 'CoinsTransaction(id: $id, amount: $amount, type: $type, reason: $reason, timestamp: $timestamp)';
  }
}
