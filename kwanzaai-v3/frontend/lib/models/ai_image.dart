class AiImage {
  final int id;
  final String imagePath;

  AiImage({required this.id, required this.imagePath});
  factory AiImage.fromJson(Map<String, dynamic> json){
    return AiImage(
      id: json['id'],
      imagePath: json['image_path']
    );
  }
}