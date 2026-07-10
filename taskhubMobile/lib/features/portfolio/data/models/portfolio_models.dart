import 'package:json_annotation/json_annotation.dart';

part 'portfolio_models.g.dart';

@JsonSerializable(explicitToJson: true)
class PortfolioItemResponse {
  final int id;
  final String title;
  final String? description;
  final String? projectUrl;
  final List<String> imageUrls;
  final int displayOrder;
  final String createdAt;

  PortfolioItemResponse({
    required this.id,
    required this.title,
    this.description,
    this.projectUrl,
    this.imageUrls = const [],
    this.displayOrder = 0,
    required this.createdAt,
  });

  factory PortfolioItemResponse.fromJson(Map<String, dynamic> json) =>
      _$PortfolioItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioItemResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreatePortfolioItemRequest {
  final String title;
  final String? description;
  final String? projectUrl;
  final List<String>? imageUrls;

  CreatePortfolioItemRequest({
    required this.title,
    this.description,
    this.projectUrl,
    this.imageUrls,
  });

  Map<String, dynamic> toJson() => _$CreatePortfolioItemRequestToJson(this);
}
