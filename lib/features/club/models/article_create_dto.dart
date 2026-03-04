class ArticleCreateDto {
  final String path;
  final String title;
  final String content;
  final String? identity;
  final String? category;
  final int? articleOrder;

  ArticleCreateDto({
    required this.path,
    required this.title,
    required this.content,
    this.identity,
    this.category,
    this.articleOrder,
  });

  factory ArticleCreateDto.fromJson(Map<String, dynamic> json) {
    return ArticleCreateDto(
      path: json['path'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      identity: json['identity'] as String?,
      category: json['category'] as String?,
      articleOrder: json['articleOrder'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'title': title,
      'content': content,
      'identity': identity,
      'category': category,
      'articleOrder': articleOrder,
    };
  }
}
