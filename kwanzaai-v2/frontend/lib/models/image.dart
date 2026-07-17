class Image {
  final int id;
  final String imagePath;

  Image({required this.id, required this.imagePath});
  factory Image.fromJson(Map<String, dynamic> json){
    return Image(
      id: json['id'],
      imagePath: json['image_path']
    );
  }
}