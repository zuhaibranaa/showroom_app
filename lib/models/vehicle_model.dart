import 'package:json_annotation/json_annotation.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel {
  final String id;
  final String agencyId;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final String vin;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Add Used Bike fields
  final String? receiptNo;
  final double? eChallanFine;
  final DateTime? biometricAvailableDate;
  final String? biometricPhone;
  final String? company;
  final String? engineCC;
  final String? documentStatus;
  final String? source;
  final String? engineNo;
  final String? chassisNo;
  final String? plateNo;
  final String? sellerName;
  final String? sellerCNIC;
  final String? sellerPhone;
  final double? priceAmount;
  final bool isZeroMeter;

  VehicleModel({
    required this.id,
    this.agencyId = '',
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.vin,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.receiptNo,
    this.eChallanFine,
    this.biometricAvailableDate,
    this.biometricPhone,
    this.company,
    this.engineCC,
    this.documentStatus,
    this.source,
    this.engineNo,
    this.chassisNo,
    this.plateNo,
    this.sellerName,
    this.sellerCNIC,
    this.sellerPhone,
    this.priceAmount,
    this.isZeroMeter = false,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);

  VehicleModel copyWith({
    String? id,
    String? agencyId,
    String? make,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    String? vin,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? receiptNo,
    double? eChallanFine,
    DateTime? biometricAvailableDate,
    String? biometricPhone,
    String? company,
    String? engineCC,
    String? documentStatus,
    String? source,
    String? engineNo,
    String? chassisNo,
    String? plateNo,
    String? sellerName,
    String? sellerCNIC,
    String? sellerPhone,
    double? priceAmount,
    bool? isZeroMeter,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      vin: vin ?? this.vin,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receiptNo: receiptNo ?? this.receiptNo,
      eChallanFine: eChallanFine ?? this.eChallanFine,
      biometricAvailableDate: biometricAvailableDate ?? this.biometricAvailableDate,
      biometricPhone: biometricPhone ?? this.biometricPhone,
      company: company ?? this.company,
      engineCC: engineCC ?? this.engineCC,
      documentStatus: documentStatus ?? this.documentStatus,
      source: source ?? this.source,
      engineNo: engineNo ?? this.engineNo,
      chassisNo: chassisNo ?? this.chassisNo,
      plateNo: plateNo ?? this.plateNo,
      sellerName: sellerName ?? this.sellerName,
      sellerCNIC: sellerCNIC ?? this.sellerCNIC,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      priceAmount: priceAmount ?? this.priceAmount,
      isZeroMeter: isZeroMeter ?? this.isZeroMeter,
    );
  }
}
