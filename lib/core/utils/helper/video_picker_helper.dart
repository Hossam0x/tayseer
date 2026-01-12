import 'package:image_picker/image_picker.dart';

class VideoPickerHelper {
  final ImagePicker _picker = ImagePicker();

  /// 📁 Gallery
  Future<XFile?> pickFromGallery() async {
    try {
      return await _picker.pickVideo(source: ImageSource.gallery);
    } catch (e) {
      print('Error picking video from gallery: $e');
      return null;
    }
  }

  /// 📷 Camera
  Future<XFile?> pickFromCamera() async {
    try {
      return await _picker.pickVideo(source: ImageSource.camera);
    } catch (e) {
      print('Error picking video from camera: $e');
      return null;
    }
  }
}
