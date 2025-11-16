class MemberModel {
  final String identity;
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

  MemberModel({
    required this.identity,
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

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      identity: json['identity'] as String,
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
      'identity': identity,
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

class MemberData {
  int totalCount;
  int totalPages;
  List<MemberModel> data;

  MemberData(
      {required this.totalCount, required this.totalPages, required this.data});

  factory MemberData.fromJson(Map<String, dynamic> json) {
    return MemberData(
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
      data: (json['data'] as List<dynamic>)
          .map((json) => MemberModel.fromJson(json))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TotalCount': totalCount,
      'TotalPages': totalPages,
      'Data': data.map((member) => member.toJson()).toList(),
    };
  }
}
