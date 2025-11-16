class CreateClientAppModel {
  final String? applicationName;
  final String? description;
  final String? homepageUrl;
  final List<String>? redirectUris;
  final String? logoUrl;

  CreateClientAppModel({
    this.applicationName,
    this.description,
    this.homepageUrl,
    this.redirectUris,
    this.logoUrl,
  });

  factory CreateClientAppModel.fromJson(Map<String, dynamic> json) {
    return CreateClientAppModel(
      applicationName: json['applicationName'] as String?,
      description: json['description'] as String?,
      homepageUrl: json['homepageUrl'] as String?,
      redirectUris: (json['redirectUris'] as List?)?.map((e) => e as String).toList(),
      logoUrl: json['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationName': applicationName,
      'description': description,
      'homepageUrl': homepageUrl,
      'redirectUris': redirectUris,
      'logoUrl': logoUrl,
    };
  }
}