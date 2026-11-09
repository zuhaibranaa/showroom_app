import 'package:equatable/equatable.dart';

/// Domain entity for a sale. Encapsulates sale-specific business rules.
class SaleEntity extends Equatable {
  final String id;
  final String vehicleId;
  final String buyerName;
  final String purchaserCNIC;
  final String buyerPhone;
  final double salePrice;
  final double purchasePrice;
  final double profit;
  final double received;
  final bool hasBalance;
  final String? dealerId;
  final String? receiptNo;
  final String? referenceNo;
  final String? numberPlate;
  final String? soldWithNumber;
  final String? documentStatus;
  final DateTime saleDate;
  final String agencyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SaleEntity({
    required this.id,
    required this.vehicleId,
    required this.buyerName,
    required this.purchaserCNIC,
    required this.buyerPhone,
    required this.salePrice,
    required this.purchasePrice,
    required this.profit,
    required this.received,
    required this.hasBalance,
    this.dealerId,
    this.receiptNo,
    this.referenceNo,
    this.numberPlate,
    this.soldWithNumber,
    this.documentStatus,
    required this.saleDate,
    required this.agencyId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the sale price is valid (not less than purchase price).
  bool get isPriceValid => salePrice >= purchasePrice;

  /// The outstanding balance on this sale.
  double get balance => salePrice - received;

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        buyerName,
        purchaserCNIC,
        buyerPhone,
        salePrice,
        purchasePrice,
        profit,
        received,
        hasBalance,
        dealerId,
        receiptNo,
        referenceNo,
        numberPlate,
        soldWithNumber,
        documentStatus,
        saleDate,
        agencyId,
        createdAt,
        updatedAt,
      ];

  SaleEntity copyWith({
    String? id,
    String? vehicleId,
    String? buyerName,
    String? purchaserCNIC,
    String? buyerPhone,
    double? salePrice,
    double? purchasePrice,
    double? profit,
    double? received,
    bool? hasBalance,
    String? dealerId,
    String? receiptNo,
    String? referenceNo,
    String? numberPlate,
    String? soldWithNumber,
    String? documentStatus,
    DateTime? saleDate,
    String? agencyId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      buyerName: buyerName ?? this.buyerName,
      purchaserCNIC: purchaserCNIC ?? this.purchaserCNIC,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      profit: profit ?? this.profit,
      received: received ?? this.received,
      hasBalance: hasBalance ?? this.hasBalance,
      dealerId: dealerId ?? this.dealerId,
      receiptNo: receiptNo ?? this.receiptNo,
      referenceNo: referenceNo ?? this.referenceNo,
      numberPlate: numberPlate ?? this.numberPlate,
      soldWithNumber: soldWithNumber ?? this.soldWithNumber,
      documentStatus: documentStatus ?? this.documentStatus,
      saleDate: saleDate ?? this.saleDate,
      agencyId: agencyId ?? this.agencyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
