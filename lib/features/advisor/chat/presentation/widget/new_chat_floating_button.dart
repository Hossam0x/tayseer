import 'package:tayseer/my_import.dart';

class NewChatFloatingButton extends StatelessWidget {
  const NewChatFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final rightMargin = isMobile ? 16.0 : 20.0;
    final bottomMargin = isMobile ? 70.0 : 80.0;
    final borderRadius = isMobile ? 12.0 : 15.0;

    return Container(
      margin: EdgeInsets.only(right: rightMargin, bottom: bottomMargin),
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFFFFEBF0),
        foregroundColor: const Color(0xFFE96E88),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: Color(0xFFE96E88), width: 2),
        ),
        icon: Icon(
          Icons.diamond_outlined,
          color: Colors.amber,
          size: isMobile ? 18 : 20,
        ),
        label: Text(
          "إضافة محادثة جديدة",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ),
    );
  }
}
