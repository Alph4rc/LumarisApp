class CreateClientAppModel {
  final String? applicationName;
  final String? description;
  final String? homepageUrl;
  final List<String>? redirectUris;
  final String? logoUrl;
  final bool? isNeedEMail;
  final bool? supportsPkce;

  CreateClientAppModel({
    this.applicationName,
    this.description,
    this.homepageUrl,
    this.redirectUris,
    this.logoUrl,
    this.isNeedEMail,
    this.supportsPkce,
  });

  factory CreateClientAppModel.fromJson(Map<String, dynamic> json) {
    return CreateClientAppModel(
      applicationName: json['applicationName'] as String?,
      description: json['description'] as String?,
      homepageUrl: json['homepageUrl'] as String?,
      redirectUris: (json['redirectUris'] as List?)?.map((e) => e as String).toList(),
      logoUrl: json['logoUrl'] as String?,
      isNeedEMail: json['isNeedEMail'] as bool?,
      supportsPkce: json['supportsPkce'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationName': applicationName,
      'description': description,
      'homepageUrl': homepageUrl,
      'redirectUris': redirectUris,
      'logoUrl': logoUrl,
      'isNeedEMail': isNeedEMail,
      'supportsPkce': supportsPkce,
    };
  }
}