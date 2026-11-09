// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
      id: json['id'] as String,
      agencyId: json['agencyId'] as String? ?? '',
      vehicleId: json['vehicleId'] as String?,
      kind: json['kind'] as String? ?? 'showroom',
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agencyId': instance.agencyId,
      'vehicleId': instance.vehicleId,
      'kind': instance.kind,
      'category': instance.category,
      'amount': instance.amount,
      'notes': instance.notes,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
