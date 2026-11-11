import 'package:equatable/equatable.dart';

/// Domain entity for an agency-specific retail price of a vehicle make/model.
class RetailPriceEntity extends Equatable {
  final String id;
  final String make;
  final String model;
  final String agencyId;
  final double price;
  final DateTime updatedAt;

  const RetailPriceEntity({
    required this.id,
    required this.make,
    required this.model,
    required this.agencyId,
    required this.price,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, make, model, agencyId, price, updatedAt];

  RetailPriceEntity copyWith({
    String? id,
    String? make,
    String? model,
    String? agencyId,
    double? price,
    DateTime? updatedAt,
  }) {
    return RetailPriceEntity(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      agencyId: agencyId ?? this.agencyId,
      price: price ?? this.price,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
