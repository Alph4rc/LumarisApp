class CategoryModel {
  final String? id;
  final String name;
  final int? order;
  final String? description;

  CategoryModel({
    this.id,
    required this.name,
    this.order,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      order: json['order'] as int?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'description': description,
    };
  }
}

class ArticleModel {
  final String path;
  final String title;
  final String content;
  final DateTime lastWriteTime;
  final String? identity;
  final String? categoryId;
  final CategoryModel? category;
  final int? articleOrder;

  ArticleModel({
    required this.path,
    required this.title,
    required this.content,
    required this.lastWriteTime,
    this.identity,
    this.categoryId,
    this.category,
    this.articleOrder,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      path: json['path'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      lastWriteTime: DateTime.parse(json['lastWriteTime'] as String),
      identity: json['identity'] as String?,
      categoryId: json['categoryId'] as String?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      articleOrder: json['articleOrder'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'title': title,
      'content': content,
      'lastWriteTime': lastWriteTime.toIso8601String(),
      'identity': identity,
      'categoryId': categoryId,
      'category': category?.toJson(),
      'articleOrder': articleOrder,
    };
  }
}
