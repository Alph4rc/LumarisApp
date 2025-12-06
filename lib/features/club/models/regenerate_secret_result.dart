class RegenerateSecretResult {
  final String clientId;
  final String newSecret;

  RegenerateSecretResult({
    required this.clientId,
    required this.newSecret,
  });

  factory RegenerateSecretResult.fromJson(Map<String, dynamic> json) {
    return RegenerateSecretResult(
      clientId: json['clientId'] as String,
      newSecret: json['newSecret'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'newSecret': newSecret,
    };
  }
}