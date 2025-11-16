class StudentModel {
  final String userName;
  final String userId;
  final String academy;
  final String politicalLandscape;
  final String gender;
  final String className;
  final String phoneNum;
  final DateTime joinTime;
  final String passwordHash;
  final String? eMail;

  StudentModel({
    required this.userName,
    required this.userId,
    required this.academy,
    required this.politicalLandscape,
    required this.gender,
    required this.className,
    required this.phoneNum,
    required this.joinTime,
    required this.passwordHash,
    this.eMail,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      userName: json['userName'] as String,
      userId: json['userId'] as String,
      academy: json['academy'] as String,
      politicalLandscape: json['politicalLandscape'] as String,
      gender: json['gender'] as String,
      className: json['className'] as String,
      phoneNum: json['phoneNum'] as String,
      joinTime: DateTime.parse(json['joinTime'] as String),
      passwordHash: json['passwordHash'] as String,
      eMail: json['eMail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userId': userId,
      'academy': academy,
      'politicalLandscape': politicalLandscape,
      'gender': gender,
      'className': className,
      'phoneNum': phoneNum,
      'joinTime': joinTime.toIso8601String(),
      'passwordHash': passwordHash,
      'eMail': eMail,
    };
  }
}