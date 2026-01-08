import 'package:tayseer/my_import.dart';

class CustomFabMenu extends StatefulWidget {
  // استقبال حالة الظهور من الخارج
  final bool isVisible;

  const CustomFabMenu({super.key, required this.isVisible});

  @override
  State<CustomFabMenu> createState() => _CustomFabMenuState();
}

class _CustomFabMenuState extends State<CustomFabMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  // حالة القائمة (مفتوحة أم مغلقة)
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  // هذه الدالة تراقب التغيرات القادمة من الأب
  @override
  void didUpdateWidget(covariant CustomFabMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إذا تغيرت الحالة من مرئي إلى غير مرئي
    if (oldWidget.isVisible == true && widget.isVisible == false) {
      // وكانت القائمة مفتوحة، قم بإغلاقها
      if (_isExpanded) {
        _closeMenu();
      }
    }
  }

  void _closeMenu() {
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // القائمة المنسدلة (تظهر فقط عند الفتح)
        ..._buildExpandableItems(),

        // الزر الرئيسي الكبير
        GestureDetector(
          onTap: _toggleMenu,
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              // اللون الوردي المتدرج او الثابت حسب الصورة
              gradient: AppColors.defaultGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.kprimaryColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Icon(Icons.add, color: Colors.white, size: 32.sp),
            ),
          ),
        ),
      ],
    );
  }

  // دالة لبناء عناصر القائمة
  List<Widget> _buildExpandableItems() {
    // قائمة العناصر
    final items = [
      _MenuItem(icon: Icons.edit_outlined, label: "بوست", onTap: () {}),
      _MenuItem(icon: Icons.play_circle_outline, label: "فيديو", onTap: () {}),
      _MenuItem(icon: Icons.movie_outlined, label: "ريلز", onTap: () {}),
      _MenuItem(icon: Icons.add_circle_outline, label: "ستوري", onTap: () {}),
    ];

    List<Widget> animatedItems = [];

    for (int i = 0; i < items.length; i++) {
      animatedItems.add(
        ScaleTransition(
          scale: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: items[i].onTap,
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i].icon, color: Colors.black, size: 18.sp),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: Styles.textStyle14.copyWith(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return animatedItems;
  }
}

// كلاس مساعد لبيانات العناصر
class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.label, required this.onTap});
}
