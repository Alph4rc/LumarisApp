class ClientApplication {
  final String? clientId;
  final String? clientSecret;
  final String? applicationName;
  final String? description;
  final String? homepageUrl;
  final String? redirectUris;
  final String? logoUrl;
  final bool? isActive;
  final bool? supportsPkce;
  final bool? isNeedEMail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientApplication({
    this.clientId,
    this.clientSecret,
    this.applicationName,
    this.description,
    this.homepageUrl,
    this.redirectUris,
    this.logoUrl,
    this.isActive,
    this.supportsPkce,
    this.isNeedEMail,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientApplication.fromJson(Map<String, dynamic> json) {
    return ClientApplication(
      clientId: json['clientId'] as String?,
      clientSecret: json['clientSecret'] as String?,
      applicationName: json['applicationName'] as String?,
      description: json['description'] as String?,
      homepageUrl: json['homepageUrl'] as String?,
      redirectUris: json['redirectUris'] as String?,
      logoUrl: json['logoUrl'] as String?,
      isActive: json['isActive'] as bool?,
      supportsPkce: json['supportsPkce'] as bool?,
      isNeedEMail: json['isNeedEMail'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
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
      'isNeedEMail': isNeedEMail,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}