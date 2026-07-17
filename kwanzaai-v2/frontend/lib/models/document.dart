class Document {
  final int id;
  final String fileName;
  final String filePath;
  final String fileType;
  
  Document({required this.id, required this.fileName, required this.filePath, required this.fileType});
  factory Document.fromJson(Map<String, dynamic> json){
    return Document(
      id: json['id'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      fileType: json['file_type']
    );
  }
}