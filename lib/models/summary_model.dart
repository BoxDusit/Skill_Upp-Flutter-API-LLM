class Summary {
  final int? id;
  final String title;
  final String content;
  final String? createdAt;

  Summary({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
  });

  // แปลงจาก JSON เป็น Object (ใช้ตอนดึงข้อมูลมาโชว์)
  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'] == null ? null : int.tryParse(json['id'].toString()),
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }

  // แปลงจาก Object เป็น JSON (ใช้ตอนส่งข้อมูลไปบันทึก)
  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content};
  }
}
