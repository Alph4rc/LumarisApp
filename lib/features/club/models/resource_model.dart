class ResourceModel {
  final String id;
  final String name;
  final String? description;
  final String? tag;

  ResourceModel({
    required this.id,
    required this.name,
    this.description,
    this.tag,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      tag: json['tag'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tag': tag,
    };
  }
}
