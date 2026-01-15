// ignore: file_names
class ImageAndNameModel {
  final String image;
  final String name;
  final int notifications;

  ImageAndNameModel({required this.image, required this.name , required this.notifications});
  factory ImageAndNameModel.fromJson(Map<String, dynamic> json) {
    return ImageAndNameModel(
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      notifications: json['notifications'] ?? 0,
    );
  }
}
