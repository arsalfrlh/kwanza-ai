class Conversation {
  final int id;
  final String title;

  Conversation({required this.id, required this.title});
  factory Conversation.fromJson(Map<String, dynamic> json){
    return Conversation(
      id: json['id'],
      title: json['title']
    );
  }
}