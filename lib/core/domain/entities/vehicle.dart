import 'package:equatable/equatable.dart';

/// Domain entity for a vehicle. Contains behavior relevant to the vehicle
/// domain, not just data transport.
class VehicleEntity extends Equatable {
  final String id;
  final String agencyId;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final String chassisNo;
  final String engineNo;
  final String plateNo;
  final String vin;
  final double priceAmount;
  final bool isZeroMeter;
  final String documentStatus;
  final DateTime purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleEntity({
    required this.id,
    required this.agencyId,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.chassisNo,
    required this.engineNo,
    required this.plateNo,
    required this.vin,
    required this.priceAmount,
    required this.isZeroMeter,
    required this.documentStatus,
    required this.purchaseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this vehicle is new (zero meter).
  bool get isNew => isZeroMeter;

  /// Whether this vehicle is used.
  bool get isUsed => !isZeroMeter;

  /// Whether the vehicle is currently in stock (not sold).
  bool get isInStock => documentStatus != 'sold';

  @override
  List<Object?> get props => [
        id,
        agencyId,
        make,
        model,
        year,
        color,
        licensePlate,
        chassisNo,
        engineNo,
        plateNo,
        vin,
        priceAmount,
        isZeroMeter,
        documentStatus,
        purchaseDate,
        createdAt,
        updatedAt,
      ];

  VehicleEntity copyWith({
    String? id,
    String? agencyId,
    String? make,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    String? chassisNo,
    String? engineNo,
    String? plateNo,
    String? vin,
    double? priceAmount,
    bool? isZeroMeter,
    String? documentStatus,
    DateTime? purchaseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      chassisNo: chassisNo ?? this.chassisNo,
      engineNo: engineNo ?? this.engineNo,
      plateNo: plateNo ?? this.plateNo,
      vin: vin ?? this.vin,
      priceAmount: priceAmount ?? this.priceAmount,
      isZeroMeter: isZeroMeter ?? this.isZeroMeter,
      documentStatus: documentStatus ?? this.documentStatus,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
