import 'package:toko/models/document.dart';
import 'package:toko/models/image.dart';

class Message {
  final int id;
  final String role;
  String message;
  bool isStreaming;
  final DateTime? createAt;
  final List<Document>? documents;
  final List<Image>? images;

  Message({required this.id, required this.role, required this.message, required this.isStreaming, this.createAt, this.documents, this.images});
  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      id: json['id'],
      role: json['role'],
      message: json['message'],
      createAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      isStreaming: false,
      documents: json['document'] != null ? (json['document'] as List).map((item) => Document.fromJson(item)).toList() : null,
      images: json['chat_image'] != null ? (json['chat_image'] as List).map((item) => Image.fromJson(item)).toList() : null
    );
  }
}