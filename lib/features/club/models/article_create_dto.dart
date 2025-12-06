class ArticleCreateDto {
  final String path;
  final String title;
  final String content;
  final String? identity;

  ArticleCreateDto({
    required this.path,
    required this.title,
    required this.content,
    this.identity,
  });

  factory ArticleCreateDto.fromJson(Map<String, dynamic> json) {
    return ArticleCreateDto(
      path: json['path'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      identity: json['identity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'title': title,
      'content': content,
      'identity': identity,
    };
  }
}