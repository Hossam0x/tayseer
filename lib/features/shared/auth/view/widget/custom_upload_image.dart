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
    // Only clear internal selection when parent explicitly removed a previously
    // provided `initialImage`, or when the parent replaced it with a new one.
    final bool parentRemovedImage =
        oldWidget.initialImage != null && widget.initialImage == null;
    final bool parentReplacedImage =
        widget.initialImage != null &&
        widget.initialImage != oldWidget.initialImage;

    if (parentRemovedImage || parentReplacedImage) {
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

/// A FormField wrapper around [UploadImageWidget] so it can participate in
/// form validation similar to `DatePickerField`.
class UploadImageFormField extends FormField<XFile> {
  UploadImageFormField({
    super.key,
    XFile? initialValue,
    required ValueChanged<XFile> onImagePicked,
    bool? isShowImage = true,
    FormFieldSetter<XFile>? onSaved,
    FormFieldValidator<XFile>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: initialValue,
         onSaved: onSaved,
         validator: validator,
         autovalidateMode: autovalidateMode,
         builder: (FormFieldState<XFile> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               UploadImageWidget(
                 isShowImage: isShowImage,
                 initialImage: state.value ?? initialValue,
                 onImagePicked: (img) {
                   state.didChange(img);
                   onImagePicked(img);
                 },
               ),
               if (state.hasError) ...[
                 const SizedBox(height: 6),
                 Text(
                   state.errorText ?? '',
                   style: const TextStyle(color: Colors.red, fontSize: 11),
                 ),
               ],
             ],
           );
         },
       );
}
