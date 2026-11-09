import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sale_model.g.dart';

DateTime _saleDateFromJson(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

DateTime? _optionalSaleDateFromJson(dynamic value) =>
    value == null ? null : _saleDateFromJson(value);

@JsonSerializable()
class SaleModel {
  final String id;
  final String agencyId;
  final String vehicleId;
  final String? dealerId;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final double purchasePrice;
  final double salePrice;
  final List<String>? imageUrls;
  final String? notes;
  @JsonKey(fromJson: _saleDateFromJson)
  final DateTime saleDate;
  @JsonKey(fromJson: _saleDateFromJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _saleDateFromJson)
  final DateTime updatedAt;

  // Bobby Motors sale fields.
  final String? receiptNo;
  final String? referenceNo;
  final String? purchaserCNIC;
  final String? purchaserFatherName;
  final String? purchaserAddress;
  final String? documentStatus;
  final double? pendingAmount;
  @JsonKey(fromJson: _optionalSaleDateFromJson)
  final DateTime? pendingDate;
  final String? paymentMode;
  final String? bank;
  final double? amountPaid;
  final double? amountReceived;
  final double? balancePending;
  @JsonKey(fromJson: _optionalSaleDateFromJson)
  final DateTime? promisedDate;
  @JsonKey(fromJson: _optionalSaleDateFromJson)
  final DateTime? dueDate;
  final String? sellerName;
  final String? sellerFatherName;
  final String? sellerCNIC;
  final String? sellerPhone;
  final String? sellerAddress;
  final String? witnessName;
  final String? witnessMobileNo;
  final String? sellersWitnessName;
  final String? sellersWitnessMobileNo;
  final String? deliveryLetter;
  final String? invoiceNo;
  final String? customerSignature;
  final String? numberPlate;
  final String? challanStatus;
  final double? challanAmount;
  final String? biometricStatus;
  @JsonKey(fromJson: _optionalSaleDateFromJson)
  final DateTime? buyerBiometricLastDate;
  final bool soldWithNumber;
  final String? registrationStatus;
  final String? remarks;

  SaleModel({
    required this.id,
    this.agencyId = '',
    required this.vehicleId,
    this.dealerId,
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
    this.receiptNo,
    this.referenceNo,
    this.purchaserCNIC,
    this.purchaserFatherName,
    this.purchaserAddress,
    this.documentStatus,
    this.pendingAmount,
    this.pendingDate,
    this.paymentMode,
    this.bank,
    this.amountPaid,
    this.amountReceived,
    this.balancePending,
    this.promisedDate,
    this.dueDate,
    this.sellerName,
    this.sellerFatherName,
    this.sellerCNIC,
    this.sellerPhone,
    this.sellerAddress,
    this.witnessName,
    this.witnessMobileNo,
    this.sellersWitnessName,
    this.sellersWitnessMobileNo,
    this.deliveryLetter,
    this.invoiceNo,
    this.customerSignature,
    this.numberPlate,
    this.challanStatus,
    this.challanAmount,
    this.biometricStatus,
    this.buyerBiometricLastDate,
    this.soldWithNumber = true,
    this.registrationStatus,
    this.remarks,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) =>
      _$SaleModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaleModelToJson(this);

  double get profit => salePrice - purchasePrice;
  double get received => amountReceived ?? amountPaid ?? 0;
  double get balance => balancePending ?? pendingAmount ?? salePrice - received;
  bool get hasBalance => balance > 0.009;

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
    String? receiptNo,
    String? referenceNo,
    String? purchaserCNIC,
    String? purchaserFatherName,
    String? purchaserAddress,
    String? documentStatus,
    double? pendingAmount,
    DateTime? pendingDate,
    String? paymentMode,
    String? bank,
    double? amountPaid,
    double? amountReceived,
    double? balancePending,
    DateTime? promisedDate,
    DateTime? dueDate,
    String? sellerName,
    String? sellerFatherName,
    String? sellerCNIC,
    String? sellerPhone,
    String? sellerAddress,
    String? witnessName,
    String? witnessMobileNo,
    String? sellersWitnessName,
    String? sellersWitnessMobileNo,
    String? deliveryLetter,
    String? invoiceNo,
    String? customerSignature,
    String? numberPlate,
    String? challanStatus,
    double? challanAmount,
    String? biometricStatus,
    DateTime? buyerBiometricLastDate,
    bool? soldWithNumber,
    String? registrationStatus,
    String? remarks,
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
      receiptNo: receiptNo ?? this.receiptNo,
      referenceNo: referenceNo ?? this.referenceNo,
      purchaserCNIC: purchaserCNIC ?? this.purchaserCNIC,
      purchaserFatherName: purchaserFatherName ?? this.purchaserFatherName,
      purchaserAddress: purchaserAddress ?? this.purchaserAddress,
      documentStatus: documentStatus ?? this.documentStatus,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      pendingDate: pendingDate ?? this.pendingDate,
      paymentMode: paymentMode ?? this.paymentMode,
      bank: bank ?? this.bank,
      amountPaid: amountPaid ?? this.amountPaid,
      amountReceived: amountReceived ?? this.amountReceived,
      balancePending: balancePending ?? this.balancePending,
      promisedDate: promisedDate ?? this.promisedDate,
      dueDate: dueDate ?? this.dueDate,
      sellerName: sellerName ?? this.sellerName,
      sellerFatherName: sellerFatherName ?? this.sellerFatherName,
      sellerCNIC: sellerCNIC ?? this.sellerCNIC,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      witnessName: witnessName ?? this.witnessName,
      witnessMobileNo: witnessMobileNo ?? this.witnessMobileNo,
      sellersWitnessName: sellersWitnessName ?? this.sellersWitnessName,
      sellersWitnessMobileNo:
          sellersWitnessMobileNo ?? this.sellersWitnessMobileNo,
      deliveryLetter: deliveryLetter ?? this.deliveryLetter,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      customerSignature: customerSignature ?? this.customerSignature,
      numberPlate: numberPlate ?? this.numberPlate,
      challanStatus: challanStatus ?? this.challanStatus,
      challanAmount: challanAmount ?? this.challanAmount,
      biometricStatus: biometricStatus ?? this.biometricStatus,
      buyerBiometricLastDate:
          buyerBiometricLastDate ?? this.buyerBiometricLastDate,
      soldWithNumber: soldWithNumber ?? this.soldWithNumber,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      remarks: remarks ?? this.remarks,
    );
  }
}
