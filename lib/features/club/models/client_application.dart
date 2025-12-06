class ClientApplication {
  final String clientId;
  final String clientSecret;
  final String applicationName;
  final String description;
  final String homepageUrl;
  final String redirectUris;
  final String logoUrl;
  final bool isActive;
  final bool supportsPkce;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientApplication({
    required this.clientId,
    required this.clientSecret,
    required this.applicationName,
    required this.description,
    required this.homepageUrl,
    required this.redirectUris,
    required this.logoUrl,
    required this.isActive,
    required this.supportsPkce,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientApplication.fromJson(Map<String, dynamic> json) {
    return ClientApplication(
      clientId: json['clientId'] as String,
      clientSecret: json['clientSecret'] as String,
      applicationName: json['applicationName'] as String,
      description: json['description'] as String,
      homepageUrl: json['homepageUrl'] as String,
      redirectUris: json['redirectUris'] as String,
      logoUrl: json['logoUrl'] as String,
      isActive: json['isActive'] as bool,
      supportsPkce: json['supportsPkce'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientSecret': clientSecret,
      'applicationName': applicationName,
      'description': description,
      'homepageUrl': homepageUrl,
      'redirectUris': redirectUris,
      'logoUrl': logoUrl,
      'isActive': isActive,
      'supportsPkce': supportsPkce,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}