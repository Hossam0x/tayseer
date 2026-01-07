import 'dart:io';
import 'package:tayseer/core/utils/helper/image_picker_helper.dart';
import 'package:tayseer/my_import.dart';

class UploadImageWidget extends StatefulWidget {
  final ValueChanged<XFile> onImagePicked;
  final bool? isShowImage;
  final XFile? initialImage;
  const UploadImageWidget({
    super.key,
    required this.onImagePicked,
    this.isShowImage,
    this.initialImage,
  });

  @override
  _UploadImageWidgetState createState() => _UploadImageWidgetState();
}

class _UploadImageWidgetState extends State<UploadImageWidget> {
  XFile? _selectedXFile;
  final ImagePickerHelper _pickerHelper = ImagePickerHelper();

  void _pickImage() async {
    final XFile? image = await _pickerHelper.pickFromGallery();
    if (image != null) {
      setState(() {
        _selectedXFile = image;
      });

      widget.onImagePicked(image);
    }
  }

  void didUpdateWidget(covariant UploadImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent cleared the initialImage (e.g., after successful upload),
    // clear internal selection so the widget shows the placeholder.
    if (widget.initialImage == null && _selectedXFile != null) {
      setState(() {
        _selectedXFile = null;
      });
    }
    // If a new initialImage is provided, prefer showing it.
    else if (widget.initialImage != null &&
        widget.initialImage != oldWidget.initialImage) {
      setState(() {
        _selectedXFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final XFile? displayFile = widget.initialImage ?? _selectedXFile;
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: context.width * 0.4,
          height: context.height * 0.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppColors.kWhiteColor,
            border: Border.all(
              width: 1.5,
              color: AppColors.kprimaryColor.withOpacity(0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: displayFile != null && widget.isShowImage == true
                ? Image.file(
                    File(displayFile.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : AppImage(AssetsData.kUpLoadImageIcon),
          ),
        ),
      ),
    );
  }
}
