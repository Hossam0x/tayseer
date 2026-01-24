import 'package:flutter/material.dart';

class FloatingWarningIcon extends StatefulWidget {
  const FloatingWarningIcon({super.key});

  @override
  State<FloatingWarningIcon> createState() => _FloatingWarningIconState();
}

class _FloatingWarningIconState extends State<FloatingWarningIcon>
    with SingleTickerProviderStateMixin {
  bool _showTooltip = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _toggleTooltip() {
    setState(() {
      _showTooltip = !_showTooltip;
      _showTooltip ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Tooltip
        if (_showTooltip)
          Positioned(
            bottom: 70,
            left: 0,
            child: FadeTransition(
              opacity: _controller,
              child: ScaleTransition(
                scale: _controller,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFD64D65).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: Color(0xFFD64D65),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'إذا لم تدخل الجلسة خلال أول 5 دقائق سيتم إلغاؤها ولن تحصل على أموال الجلسة وسيقل التقييم الخاص بك',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        /// Floating Button
        GestureDetector(
          onTap: _toggleTooltip,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFD64D65),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD64D65).withOpacity(0.45),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}
