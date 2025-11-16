class ArticleModel {
  final String path;
  final String title;
  final String content;
  final DateTime lastWriteTime;
  final String? identity;

  ArticleModel({
    required this.path,
    required this.title,
    required this.content,
    required this.lastWriteTime,
    this.identity,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      path: json['path'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      lastWriteTime: DateTime.parse(json['lastWriteTime'] as String),
      identity: json['identity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'title': title,
      'content': content,
      'lastWriteTime': lastWriteTime.toIso8601String(),
      'identity': identity,
    };
  }
}