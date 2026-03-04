class ArticleUpdateDto {
  final String title;
  final String content;
  final String? identity;
  final String? category;
  final int? articleOrder;

  ArticleUpdateDto({
    required this.title,
    required this.content,
    this.identity,
    this.category,
    this.articleOrder,
  });

  factory ArticleUpdateDto.fromJson(Map<String, dynamic> json) {
    return ArticleUpdateDto(
      title: json['title'] as String,
      content: json['content'] as String,
      identity: json['identity'] as String?,
      category: json['category'] as String?,
      articleOrder: json['articleOrder'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'identity': identity,
      'category': category,
      'articleOrder': articleOrder,
    };
  }
}
