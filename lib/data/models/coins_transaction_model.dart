import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/coins_transaction.dart';

part 'coins_transaction_model.g.dart';

@HiveType(typeId: 8)
@JsonSerializable()
class CoinsTransactionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int amount;

  @HiveField(2)
  final CoinsTransactionType type;

  @HiveField(3)
  final String reason;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final Map<String, dynamic> metadata;

  const CoinsTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.reason,
    required this.timestamp,
    this.metadata = const {},
  });

  factory CoinsTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$CoinsTransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoinsTransactionModelToJson(this);

  factory CoinsTransactionModel.fromEntity(CoinsTransaction transaction) {
    return CoinsTransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      type: transaction.type,
      reason: transaction.reason,
      timestamp: transaction.timestamp,
      metadata: transaction.metadata,
    );
  }

  CoinsTransaction toEntity() {
    return CoinsTransaction(
      id: id,
      amount: amount,
      type: type,
      reason: reason,
      timestamp: timestamp,
      metadata: metadata,
    );
  }

  CoinsTransactionModel copyWith({
    String? id,
    int? amount,
    CoinsTransactionType? type,
    String? reason,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return CoinsTransactionModel(
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
    return other is CoinsTransactionModel &&
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
    return 'CoinsTransactionModel(id: $id, amount: $amount, type: $type, reason: $reason, timestamp: $timestamp)';
  }
}
