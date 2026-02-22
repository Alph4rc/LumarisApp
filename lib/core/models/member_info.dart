import 'package:ios_club_app/features/club/models/member_model.dart';

class MemberInfo {
  final Map<String, dynamic> memberData;
  final MemberModel? info;

  MemberInfo({
    required this.memberData,
    this.info,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      memberData: Map<String, dynamic>.from(json['memberData'] ?? {}),
      info: json['info'] != null ? MemberModel.fromJson(json['info']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberData': memberData,
      if (info != null) 'info': info!.toJson(),
    };
  }
}
