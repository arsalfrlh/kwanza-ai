import 'package:toko/models/user.dart';

class Message {
  final int id;
  final String role;
  String message;
  final DateTime? createAt;
  final User? user;
  bool isStreaming;

  Message({required this.id, required this.role, required this.message, this.createAt, this.user, required this.isStreaming});
  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      id: json['id'],
      role: json['role'],
      message: json['message'],
      createAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      isStreaming: false
    );
  }
}