import 'package:tayseer/my_import.dart';

class CustomSwitchWidget extends StatefulWidget {
  final ValueChanged<bool>? onChanged;

  const CustomSwitchWidget({super.key, this.onChanged});

  @override
  State<CustomSwitchWidget> createState() => _CustomSwitchWidgetState();
}

class _CustomSwitchWidgetState extends State<CustomSwitchWidget> {
  late bool value;

  @override
  void initState() {
    super.initState();
    // value = kCurrentUserData?.isNotify ?? false;
  }

  void toggleSwitch() {
    setState(() {
      value = !value;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: context.width * 0.11,
        height: context.height * 0.03,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HexColor('b5b5b5'),
              HexColor('f0f0f0'),
              HexColor('f0f0f0'),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? AppColors.kgreen : Colors.grey,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
