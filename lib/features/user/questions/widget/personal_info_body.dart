import 'dart:io';
import 'package:tayseer/my_import.dart';

class PersonalInfoBody extends StatefulWidget {
  const PersonalInfoBody({super.key});

  @override
  State<PersonalInfoBody> createState() => _PersonalInfoBodyState();
}

class _PersonalInfoBodyState extends State<PersonalInfoBody> {
  final TextEditingController nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<File> images = [];

  // ✅ Image Picker ONLY (no cropper)
  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      images.add(File(picked.path));
    });
  }

  void removeImage(int index) {
    setState(() => images.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: context.height * 0.05),

                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                Text(
                  context.tr('add_your_personal_details'),
                  style: Styles.textStyle20.copyWith(
                    fontWeight: FontWeight.bold,
                    color: HexColor('590d1c'),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextFormField(isName: true),
                const SizedBox(height: 20),

                AddImageCard(onTap: pickImage),
                const SizedBox(height: 16),

                ImageGrid(
                  images: images,
                  onAdd: pickImage,
                  onRemove: removeImage,
                ),
                SizedBox(height: context.height * 0.03),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomBotton(
                    width: context.width,
                    title: context.tr('next'),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- CUSTOM WIDGETS ----------------

class AddImageCard extends StatelessWidget {
  final VoidCallback onTap;
  const AddImageCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.kprimaryColor),
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.camera_alt, size: 36, color: Colors.pink),
            SizedBox(height: 8),
            Text('أضف صورة خاصة بك', style: TextStyle(color: Colors.pink)),
          ],
        ),
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const ImageGrid({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: images.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        if (index == images.length) {
          return AddGridItem(onTap: onAdd);
        }
        return ImageItem(file: images[index], onRemove: () => onRemove(index));
      },
    );
  }
}

class ImageItem extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const ImageItem({super.key, required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: -6,
          left: -6,
          child: IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}

class AddGridItem extends StatelessWidget {
  final VoidCallback onTap;
  const AddGridItem({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.pink, width: 1.5),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 32, color: Colors.pink),
        ),
      ),
    );
  }
}
