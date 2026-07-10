// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortfolioItemResponse _$PortfolioItemResponseFromJson(
  Map<String, dynamic> json,
) => PortfolioItemResponse(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  projectUrl: json['projectUrl'] as String?,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$PortfolioItemResponseToJson(
  PortfolioItemResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'projectUrl': instance.projectUrl,
  'imageUrls': instance.imageUrls,
  'displayOrder': instance.displayOrder,
  'createdAt': instance.createdAt,
};

CreatePortfolioItemRequest _$CreatePortfolioItemRequestFromJson(
  Map<String, dynamic> json,
) => CreatePortfolioItemRequest(
  title: json['title'] as String,
  description: json['description'] as String?,
  projectUrl: json['projectUrl'] as String?,
  imageUrls: (json['imageUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CreatePortfolioItemRequestToJson(
  CreatePortfolioItemRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'projectUrl': instance.projectUrl,
  'imageUrls': instance.imageUrls,
};
