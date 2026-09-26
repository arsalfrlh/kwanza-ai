import 'package:toko/models/ai_document.dart';
import 'package:toko/models/ai_image.dart';

class AiMessage {
  final int? id;
  final String role;
  String message;
  final DateTime? createAt;
  final List<AiDocument> documents;
  final List<AiImage> images;
  bool isStreaming;

  AiMessage({this.id, required this.role, required this.message, this.createAt, required this.documents, required this.images, required this.isStreaming});
  factory AiMessage.fromJson(Map<String, dynamic> json){
    return AiMessage(
      id: json['id'],
      role: json['role'],
      message: json['message'],
      createAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      documents: json['documents'] != null ? (json['documents'] as List).map((item) => AiDocument.fromJson(item)).toList() : [],
      images: json['images'] != null ? (json['images'] as List).map((item) => AiImage.fromJson(item)).toList() : [],
      isStreaming: false
    );
  }
}