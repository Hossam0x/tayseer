import 'package:tayseer/my_import.dart';

class CusttomImageGrid extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const CusttomImageGrid({
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
          color: AppColors.kWhiteColor,
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
