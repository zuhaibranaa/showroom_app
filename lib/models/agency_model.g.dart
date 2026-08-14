// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgencyModel _$AgencyModelFromJson(Map<String, dynamic> json) => AgencyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AgencyModelToJson(AgencyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
