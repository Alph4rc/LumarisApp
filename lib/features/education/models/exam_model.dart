class ExamItem {
  final String name;

  final String examTime;

  final String room;

  final String seatNo;

  ExamItem({
    this.name = '',
    this.examTime = '',
    this.room = '',
    this.seatNo = '',
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    return ExamItem(
      name: json['name']?.toString() ?? '',
      examTime: json['time']?.toString() ?? '',
      room: json['location']?.toString() ?? '',
      seatNo: json['seat']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'time': examTime,
      'location': room,
      'seat': seatNo,
    };
  }
}
