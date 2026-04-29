import 'package:json_annotation/json_annotation.dart';

part 'link_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LinkModel {
  const LinkModel({
    required this.key,
    required this.name,
    this.icon,
    required this.url,
    this.description,
    required this.index,
  });

  final String key;
  final String name;
  final String? icon;
  final String url;
  final String? description;
  final int index;

  LinkModel copyWith({
    String? key,
    String? name,
    String? icon,
    String? url,
    String? description,
    int? index,
  }) {
    return LinkModel(
      key: key ?? this.key,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      url: url ?? this.url,
      description: description ?? this.description,
      index: index ?? this.index,
    );
  }

  Map<String, dynamic> toJson() => _$LinkModelToJson(this);

  factory LinkModel.fromJson(Map<String, dynamic> map) =>
      _$LinkModelFromJson(map);
}

@JsonSerializable(explicitToJson: true)
class CategoryModel {
  const CategoryModel({
    required this.key,
    required this.name,
    this.description,
    required this.icon,
    required this.index,
    this.links = const <LinkModel>[],
  });

  final String key;
  final String name;
  final String? description;
  final String icon;
  final int index;
  final List<LinkModel> links;

  CategoryModel copyWith({
    String? key,
    String? name,
    String? description,
    String? icon,
    int? index,
    List<LinkModel>? links,
  }) {
    return CategoryModel(
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      index: index ?? this.index,
      links: links ?? this.links,
    );
  }

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  factory CategoryModel.fromJson(Map<String, dynamic> map) =>
      _$CategoryModelFromJson(map);
}
