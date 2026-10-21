// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleModel _$SaleModelFromJson(Map<String, dynamic> json) => SaleModel(
      id: json['id'] as String,
      agencyId: json['agencyId'] as String? ?? '',
      vehicleId: json['vehicleId'] as String,
      dealerId: json['dealerId'] as String,
      buyerName: json['buyerName'] as String,
      buyerEmail: json['buyerEmail'] as String,
      buyerPhone: json['buyerPhone'] as String,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      saleDate: DateTime.parse(json['saleDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      receiptNo: json['receiptNo'] as String?,
      purchaserCNIC: json['purchaserCNIC'] as String?,
      documentStatus: json['documentStatus'] as String?,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble(),
      pendingDate: json['pendingDate'] == null
          ? null
          : DateTime.parse(json['pendingDate'] as String),
    );

Map<String, dynamic> _$SaleModelToJson(SaleModel instance) => <String, dynamic>{
      'id': instance.id,
      'agencyId': instance.agencyId,
      'vehicleId': instance.vehicleId,
      'dealerId': instance.dealerId,
      'buyerName': instance.buyerName,
      'buyerEmail': instance.buyerEmail,
      'buyerPhone': instance.buyerPhone,
      'purchasePrice': instance.purchasePrice,
      'salePrice': instance.salePrice,
      'imageUrls': instance.imageUrls,
      'notes': instance.notes,
      'saleDate': instance.saleDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'receiptNo': instance.receiptNo,
      'purchaserCNIC': instance.purchaserCNIC,
      'documentStatus': instance.documentStatus,
      'pendingAmount': instance.pendingAmount,
      'pendingDate': instance.pendingDate?.toIso8601String(),
    };
