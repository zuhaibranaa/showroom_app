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
    );
  }
}
