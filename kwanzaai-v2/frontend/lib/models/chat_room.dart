class ChatRoom {
  final int id;
  final String title;
  final DateTime? createAt;

  ChatRoom({required this.id, required this.title, this.createAt});
  factory ChatRoom.fromJson(Map<String, dynamic> json){
    return ChatRoom(
      id: json['id'],
      title: json['title'],
      createAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null
    );
  }
}