class ArticleUpdateDto {
  final String title;
  final String content;
  final String? identity;

  ArticleUpdateDto({
    required this.title,
    required this.content,
    this.identity,
  });

  factory ArticleUpdateDto.fromJson(Map<String, dynamic> json) {
    return ArticleUpdateDto(
      title: json['title'] as String,
      content: json['content'] as String,
      identity: json['identity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'identity': identity,
    };
  }
}