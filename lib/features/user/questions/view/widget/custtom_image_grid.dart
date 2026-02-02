import 'package:tayseer/my_import.dart';

class CusttomImageGrid extends StatelessWidget {
  final List<dynamic> imageUrls; // ⭐ Accepts both String (URLs) and File objects
  final VoidCallback onAdd;
  final Function(int) onRemove;
  
  const CusttomImageGrid({
    super.key,
    required this.imageUrls, // ⭐ Can be List<String> or List<File>
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageUrls.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        if (index == imageUrls.length) {
          return AddGridItem(onTap: onAdd);
        }
        return ImageItem(
          imageData: imageUrls[index], // ⭐ Can be either File or String
          onRemove: () => onRemove(index),
        );
      },
    );
  }
}

class ImageItem extends StatelessWidget {
  final dynamic imageData; // ⭐ Can be File or String
  final VoidCallback onRemove;
  
  const ImageItem({
    super.key, 
    required this.imageData, 
    required this.onRemove,
  });

  // ⭐ Check if it's a local File object
  bool get isFile => imageData is File;
  
  // ⭐ Check if it's a network URL
  bool get isNetworkUrl => imageData is String && 
      (imageData.startsWith('http://') || imageData.startsWith('https://'));
  
  // ⭐ Check if it's a local file path
  bool get isLocalPath => imageData is String && 
      !imageData.startsWith('http://') && 
      !imageData.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildImage(),
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

  Widget _buildImage() {
    // ⭐ File object (from image picker)
    if (isFile) {
      return Image.file(
        imageData as File,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }
    
    // ⭐ Network URL (from API)
    if (isNetworkUrl) {
      return CachedNetworkImage(
        imageUrl: imageData as String,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: AppColors.kprimaryColor,
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) {
          return _buildErrorWidget();
        },
      );
    }
    
    // ⭐ Local file path (fallback)
    if (isLocalPath) {
      return Image.file(
        File(imageData as String),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }
    
    // ⭐ Unknown type
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 40,
        ),
      ),
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