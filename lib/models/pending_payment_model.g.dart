// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingPaymentModel _$PendingPaymentModelFromJson(Map<String, dynamic> json) =>
    PendingPaymentModel(
      id: json['id'] as String,
      agencyId: json['agencyId'] as String? ?? '',
      saleId: json['saleId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      buyerName: json['buyerName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PendingPaymentModelToJson(
        PendingPaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agencyId': instance.agencyId,
      'saleId': instance.saleId,
      'vehicleId': instance.vehicleId,
      'buyerName': instance.buyerName,
      'amount': instance.amount,
      'dueDate': instance.dueDate?.toIso8601String(),
      'status': instance.status,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
