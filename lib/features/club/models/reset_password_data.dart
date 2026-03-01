class ResetPasswordData {
  final String userId;
  final String newPassword;

  ResetPasswordData({
    required this.userId,
    required this.newPassword,
  });

  factory ResetPasswordData.fromJson(Map<String, dynamic> json) {
    return ResetPasswordData(
      userId: json['userId'] as String,
      newPassword: json['newPassword'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'newPassword': newPassword,
    };
  }
}
