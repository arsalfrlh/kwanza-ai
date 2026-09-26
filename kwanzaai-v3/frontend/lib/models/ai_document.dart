class AiDocument {
  final int id;
  final String originalFileName;
  final String fileName;
  final String fileType;
  final String filePath;

  AiDocument({required this.id, required this.originalFileName, required this.fileName, required this.fileType, required this.filePath});
  factory AiDocument.fromJson(Map<String, dynamic> json){
    return AiDocument(
      id: json['id'],
      originalFileName: json['original_file_name'],
      fileName: json['file_name'],
      fileType: json['file_type'],
      filePath: json['file_path']
    );
  }
}