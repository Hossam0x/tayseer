import 'package:tayseer/my_import.dart';

class EventImageSlider extends StatefulWidget {
  final List<String> images; // ✅ List مباشرة بدل String

  const EventImageSlider({super.key, required this.images});

  @override
  State<EventImageSlider> createState() => _EventImageSliderState();
}

class _EventImageSliderState extends State<EventImageSlider> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ نستخدم widget.images مباشرة
    if (widget.images.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: context.height * 0.4,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _buildImagePage(widget.images[index]);
            },
          ),
        ),

        if (widget.images.length > 1)
          Positioned(
            top: context.height * 0.25,
            child: _DotsIndicator(
              count: widget.images.length,
              currentIndex: _currentIndex,
            ),
          ),
      ],
    );
  }

  Widget _buildImagePage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stack) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 280,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _DotsIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8, // ← Active أكبر
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? HexColor('550c1b') : Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
