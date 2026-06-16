class ChatRoom {
  final int id;
  final String chatName;
  final DateTime? createAt;

  ChatRoom({required this.id, required this.chatName, required this.createAt});
  factory ChatRoom.fromJson(Map<String, dynamic> json){
    return ChatRoom(
      id: json['id'],
      chatName: json['chat_name'],
      createAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null
    );
  }
}