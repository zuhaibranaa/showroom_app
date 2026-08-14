import 'package:json_annotation/json_annotation.dart';

part 'sale_model.g.dart';

@JsonSerializable()
class SaleModel {
  final String id;
  final String agencyId;
  final String vehicleId;
  final String dealerId;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final double purchasePrice;
  final double salePrice;
  final List<String>? imageUrls;
  final String? notes;
  final DateTime saleDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SaleModel({
    required this.id,
    this.agencyId = '',
    required this.vehicleId,
    required this.dealerId,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.purchasePrice,
    required this.salePrice,
    this.imageUrls,
    this.notes,
    required this.saleDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) =>
      _$SaleModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaleModelToJson(this);

  double get profit => salePrice - purchasePrice;

  SaleModel copyWith({
    String? id,
    String? agencyId,
    String? vehicleId,
    String? dealerId,
    String? buyerName,
    String? buyerEmail,
    String? buyerPhone,
    double? purchasePrice,
    double? salePrice,
    List<String>? imageUrls,
    String? notes,
    DateTime? saleDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      vehicleId: vehicleId ?? this.vehicleId,
      dealerId: dealerId ?? this.dealerId,
      buyerName: buyerName ?? this.buyerName,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      imageUrls: imageUrls ?? this.imageUrls,
      notes: notes ?? this.notes,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
