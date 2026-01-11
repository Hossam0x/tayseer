// 1. انسخ هذه الدالة وضعها خارج الـ build أو في ملف منفصل
import 'package:tayseer/my_import.dart';

void showConfirmationDialog({
  required BuildContext context,
  required String imagePath, // الصورة المتغيرة
  required String title, // العنوان المتغير
  required String subtitle, // النص الفرعي المتغير
  required VoidCallback onConfirm, // الأكشن عند الضغط على نعم
}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 396,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage(
                AssetsData.homeBackgroundImage,
              ), // خلفية الديالوج ثابتة
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),

              // --- الصورة المتغيرة ---
              AppImage(imagePath, width: 76, fit: BoxFit.cover),

              SizedBox(height: 16),

              // --- العنوان المتغير ---
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 12),

              // --- النص الفرعي المتغير ---
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              SizedBox(height: 32),

              Row(
                children: [
                  // --- زر نعم (الأخضر) ---
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // يغلق الديالوج أولاً
                        onConfirm(); // ثم ينفذ الكود الخاص بك
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'نعم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 16),

                  // --- زر لا (الأحمر) ---
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // إغلاق فقط
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'لا',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}
