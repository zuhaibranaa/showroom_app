// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
      id: json['id'] as String,
      agencyId: json['agencyId'] as String? ?? '',
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      vin: json['vin'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      receiptNo: json['receiptNo'] as String?,
      eChallanFine: (json['eChallanFine'] as num?)?.toDouble(),
      biometricAvailableDate: json['biometricAvailableDate'] == null
          ? null
          : DateTime.parse(json['biometricAvailableDate'] as String),
      biometricPhone: json['biometricPhone'] as String?,
      company: json['company'] as String?,
      engineCC: json['engineCC'] as String?,
      documentStatus: json['documentStatus'] as String?,
      source: json['source'] as String?,
      engineNo: json['engineNo'] as String?,
      chassisNo: json['chassisNo'] as String?,
      plateNo: json['plateNo'] as String?,
      sellerName: json['sellerName'] as String?,
      sellerCNIC: json['sellerCNIC'] as String?,
      sellerPhone: json['sellerPhone'] as String?,
      priceAmount: (json['priceAmount'] as num?)?.toDouble(),
      isZeroMeter: json['isZeroMeter'] as bool? ?? false,
    );

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agencyId': instance.agencyId,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'color': instance.color,
      'licensePlate': instance.licensePlate,
      'vin': instance.vin,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'receiptNo': instance.receiptNo,
      'eChallanFine': instance.eChallanFine,
      'biometricAvailableDate':
          instance.biometricAvailableDate?.toIso8601String(),
      'biometricPhone': instance.biometricPhone,
      'company': instance.company,
      'engineCC': instance.engineCC,
      'documentStatus': instance.documentStatus,
      'source': instance.source,
      'engineNo': instance.engineNo,
      'chassisNo': instance.chassisNo,
      'plateNo': instance.plateNo,
      'sellerName': instance.sellerName,
      'sellerCNIC': instance.sellerCNIC,
      'sellerPhone': instance.sellerPhone,
      'priceAmount': instance.priceAmount,
      'isZeroMeter': instance.isZeroMeter,
    };
