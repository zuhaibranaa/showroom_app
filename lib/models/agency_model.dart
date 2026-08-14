import 'package:json_annotation/json_annotation.dart';

part 'agency_model.g.dart';

@JsonSerializable()
class AgencyModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgencyModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) =>
      _$AgencyModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgencyModelToJson(this);

  AgencyModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
