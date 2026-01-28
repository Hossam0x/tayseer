import 'dart:async';
import 'package:tayseer/my_import.dart';

class PhoneEditViewModel extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final BuildContext? context;

  // قائمة الدول
  final List<Map<String, String>> countries = [
    {"name": "السعودية", "code": "+966", "flag": "🇸🇦"},
    {"name": "مصر", "code": "+20", "flag": "🇪🇬"},
    {"name": "الإمارات", "code": "+971", "flag": "🇦🇪"},
    {"name": "الكويت", "code": "+965", "flag": "🇰🇼"},
    {"name": "قطر", "code": "+974", "flag": "🇶🇦"},
    {"name": "عُمان", "code": "+968", "flag": "🇴🇲"},
    {"name": "البحرين", "code": "+973", "flag": "🇧🇭"},
    {"name": "الأردن", "code": "+962", "flag": "🇯🇴"},
    {"name": "لبنان", "code": "+961", "flag": "🇱🇧"},
    {"name": "العراق", "code": "+964", "flag": "🇮🇶"},
    {"name": "المغرب", "code": "+212", "flag": "🇲🇦"},
    {"name": "الجزائر", "code": "+213", "flag": "🇩🇿"},
    {"name": "تونس", "code": "+216", "flag": "🇹🇳"},
    {"name": "تركيا", "code": "+90", "flag": "🇹🇷"},
    {"name": "الولايات المتحدة", "code": "+1", "flag": "🇺🇸"},
    {"name": "المملكة المتحدة", "code": "+44", "flag": "🇬🇧"},
  ];

  // الحالة
  String _selectedCountryCode = "+966";
  String _selectedCountryFlag = "🇸🇦";
  String _selectedCountryName = "السعودية";
  String _phoneError = '';
  bool _isLoading = false;

  String get selectedCountryCode => _selectedCountryCode;
  String get selectedCountryFlag => _selectedCountryFlag;
  String get selectedCountryName => _selectedCountryName;
  String get phoneError => _phoneError;
  bool get isLoading => _isLoading;
  bool get canProceed => phoneController.text.isNotEmpty && _phoneError.isEmpty;

  PhoneEditViewModel({String initialPhone = "", this.context}) {
    _parseInitialPhone(initialPhone);
  }

  void _parseInitialPhone(String initialPhone) {
    if (initialPhone.isNotEmpty) {
      for (var country in countries) {
        if (initialPhone.startsWith(country['code']!)) {
          _selectedCountryCode = country['code']!;
          _selectedCountryFlag = country['flag']!;
          _selectedCountryName = country['name']!;
          phoneController.text = initialPhone.substring(
            country['code']!.length,
          );
          break;
        }
      }
    }
  }

  void updateCountry(Map<String, String> country) {
    _selectedCountryCode = country['code']!;
    _selectedCountryFlag = country['flag']!;
    _selectedCountryName = country['name']!;
    validatePhone();
    notifyListeners();
  }

  void validatePhone() {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      _phoneError = '';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _phoneError = 'يجب أن يحتوي الرقم على أرقام فقط';
    } else if (phone.length < 8) {
      _phoneError = 'رقم الهاتف قصير جداً';
    } else if (phone.length > 15) {
      _phoneError = 'رقم الهاتف طويل جداً';
    } else {
      // تحقق حسب رمز الدولة
      if (_selectedCountryCode == "+966" && !phone.startsWith('5')) {
        _phoneError = 'يجب أن يبدأ الرقم السعودي بـ 5';
      } else if (_selectedCountryCode == "+20" && !phone.startsWith('1')) {
        _phoneError = 'يجب أن يبدأ الرقم المصري بـ 1';
      } else {
        _phoneError = '';
      }
    }

    notifyListeners();
  }

  void showCountryPicker() {
    if (context == null) return;

    showModalBottomSheet(
      context: context!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "اختر الدولة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Gap(10),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final item = countries[index];
                    return ListTile(
                      leading: Text(
                        item['flag']!,
                        style: TextStyle(fontSize: 24),
                      ),
                      title: Text(item['name']!),
                      trailing: Text(item['code']!),
                      onTap: () {
                        updateCountry(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> submitPhone() async {
    if (!canProceed) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final phone = phoneController.text.replaceAll(RegExp(r'\D'), '');
      final fullPhone = '$_selectedCountryCode$phone';

      // استدعاء API لتحديث رقم الهاتف
      final response = await _callUpdatePhoneAPI(
        countryCode: _selectedCountryCode,
        phone: phone,
      );

      _isLoading = false;
      notifyListeners();

      if (response['success'] == true) {
        return fullPhone;
      } else {
        if (context != null) {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'فشل تحديث رقم الهاتف'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();

      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text('خطأ في الاتصال: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> _callUpdatePhoneAPI({
    required String countryCode,
    required String phone,
  }) async {
    // TODO: استبدل هذا باستدعاء API حقيقي
    await Future.delayed(Duration(seconds: 1));

    // محاكاة استجابة ناجحة
    return {
      'success': true,
      'message': 'تم إرسال رمز التحقق بنجاح',
      'data': null,
    };
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
