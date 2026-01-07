import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<XFile?> pickFromCamera() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<List<XFile>?> pickMultipleFromGallery() async {
    try {
      return await _picker.pickMultiImage();
    } catch (e) {
      print('Error picking multiple images: $e');
      return null;
    }
  }

  Future<List<XFile>?> pickMultipleFromCamera(int count) async {
    List<XFile> images = [];
    try {
      for (int i = 0; i < count; i++) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
        );
        if (image != null) {
          images.add(image);
        }
      }
      return images;
    } catch (e) {
      print('Error picking multiple images from camera: $e');
      return null;
    }
  }

  Future<XFile?> pickVideoFromGallery() async {
    try {
      return await _picker.pickVideo(source: ImageSource.gallery);
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }
}
