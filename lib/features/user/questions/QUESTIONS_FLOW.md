# Questions Feature - Complete Flow

## Bug Fix: socialStatuses

**المشكلة:** كان `socialStatuses` معرّف كـ `static final` فبيتحسب مرة واحدة بس وقت تحميل الـ class، وده معناه لو `kCurrentUserData` كان `null` وقتها (أو الـ gender لسه ما اتحملش)، هيفضل يرجع قيمة الـ female للأبد.

**الحل:** تحويله لـ `static getter` عشان يتحسب في كل مرة بيتاستخدم:

```dart
// ❌ قبل
static final List<String> socialStatuses = kCurrentUserData?.gender == 'male' ? [...] : [...];

// ✅ بعد
static List<String> get socialStatuses => kCurrentUserData?.gender == 'male' ? [...] : [...];
```

---

## Architecture Overview

```
lib/features/user/questions/
├── data/
│   ├── models/
│   │   ├── questions_data.dart         ← Static data (lists, maps)
│   │   ├── question_page_config.dart   ← Question UI config model
│   │   └── last_question_number_model.dart
│   └── repo/
│       ├── questions_repo.dart         ← Abstract interface
│       └── questions_repo_impl.dart    ← API implementation
└── presentation/
    ├── manager/
    │   ├── questions_cubit.dart        ← State management
    │   └── questions_state.dart        ← State model
    └── views/
        ├── questions_page_view.dart    ← Main questions flow (PageView)
        ├── personal_info_view.dart     ← Image upload
        ├── commitment_view.dart        ← Name + commitment
        ├── partner_filter_view.dart    ← Partner preferences
        ├── face_verification_view.dart ← Didit SDK
        ├── account_review_view.dart
        ├── add_phone_view.dart
        ├── otp_phone_user_question.dart
        ├── verify_data_view.dart
        └── subscription_view.dart
```

---

## Entry Point

1. المستخدم يفتح `marriage_view.dart`
2. لو `compeletedData == false` → يظهر زرار "أكمل ملفك الشخصي"
3. الضغط عليه → `fetchLastQuestionNumber()` → يرجع رقم آخر سؤال وصله
4. ينتقل لـ `QuestionsPageView` مع `lastQuestionNumber` و `selectedGender`

---

## Questions Flow (26 سؤال)

| # | السؤال | النوع | شرط الظهور |
|---|--------|-------|------------|
| Q2 | الجنسية | قائمة + بحث | دايماً |
| Q3 | الدولة | قائمة + بحث | دايماً |
| Q4 | العمر | Picker (18-100) | دايماً |
| Q5 | الحالة الاجتماعية | قائمة (gender-based) | دايماً |
| Q6 | الوزن | Picker (40-160 kg) | دايماً |
| Q7 | الطول | Picker (120-220 cm) | دايماً |
| Q8 | لون البشرة | قائمة | دايماً |
| Q9 | مدخن؟ | نعم/لا | دايماً |
| Q10 | الالتزام الديني | قائمة | دايماً |
| Q11 | عنده أطفال؟ | نعم/لا | لو status != 'single' |
| Q12 | عدد الأطفال | قائمة | لو hasChildren == true |
| Q13 | وضع الأطفال | قائمة | لو hasChildren == true |
| Q14 | المستوى التعليمي | قائمة | دايماً |
| Q15 | الوظيفة | قائمة + بحث | دايماً |
| Q16 | جهة العمل | قائمة + بحث | دايماً |
| Q17 | يقبل متزوج؟ | قائمة | female أو male متزوج |
| Q18 | الحالة الصحية | قائمة | دايماً |
| Q19 | الاهتمامات | Multi-select مصنّف | دايماً |
| Q20 | الالتزام الديني (تفاصيل) | Multi-select | دايماً |
| Q21 | ترتدي حجاب؟ | نعم/لا | female فقط |
| Q22 | السيرة الذاتية | Text + AI (Gemini) | دايماً |
| Q23 | نوايا الزواج | Single-select مصنّف | دايماً |
| Q24 | قبول الأسرة | قائمة | دايماً |
| Q25 | نية السفر | قائمة | دايماً |
| Q26 | يشرب كحول؟ | نعم/لا | دايماً |

### Gender-based Logic في socialStatuses (Q5):
- **male** → `['social_single', 'social_married', 'social_divorced', 'social_widowed']`
- **female** → `['F_social_single', 'F_social_divorced', 'F_social_widowed']`
- عند الإرسال للـ API: يتعمل normalize → `'single'`, `'divorced'`, `'widowed'`

---

## After Questions Complete

```
Q26 Done
    ↓
Personal Info View (Q27)
  → رفع صورة رئيسية + 4 صور إضافية
    ↓
Commitment View (Q28)
  → إدخال الاسم الكامل + الموافقة على الشروط
    ↓
Account Review View
  → مراجعة البيانات المُدخلة
    ↓
Partner Filter View (Q29)
  → تحديد تفضيلات الشريك (عمر، دولة، جنسية)
    ↓
Subscription View
  → اختيار خطة الاشتراك
    ↓
Face Verification (Didit SDK)
  → التحقق من الهوية بالوجه
    ↓
Profile Complete ✅
```

---

## State Management (QuestionsCubit)

| Method | الوظيفة |
|--------|---------|
| `sendAnswerQuestions()` | إرسال إجابة سؤال للـ API |
| `uploadPersonalInfo()` | رفع الصور الشخصية |
| `verifyFaceWithDidit()` | التحقق بالوجه عبر Didit SDK |
| `toggleImageBlur()` | إخفاء/إظهار الصور |
| `sendPhoneNumber()` | إرسال رقم الهاتف |
| `verifyOtp()` | التحقق من OTP |
| `fetchLastQuestionNumber()` | جلب آخر سؤال وصله المستخدم |
| `submitPartnerFilter()` | حفظ تفضيلات الشريك |
| `enhanceTextWithGemini()` | تحسين النص بالـ AI |

---

## API Endpoints

| Endpoint | Method | الوظيفة |
|----------|--------|---------|
| `/answer-questions` | POST | إرسال إجابة |
| `/auth/add-images` | POST | رفع الصور |
| `/auth/change-image-blur` | PATCH | تغيير blur الصور |
| `/user/update-phone-number` | POST | تحديث الهاتف |
| `/user/verfiy-phone` | POST | التحقق من OTP |
| `/user/last-question-number` | GET | جلب آخر سؤال |
| `/user/add-preference-factors` | POST | حفظ تفضيلات الشريك |
| `/user/verify-face-didit` | GET | إنشاء جلسة التحقق بالوجه |

---

## Data Flow per Question

```
User selects answer
      ↓
_answers[questionKey] = value  (local state)
      ↓
sendAnswerQuestions() → API POST /answer-questions
      ↓
repo normalizes value (e.g. F_social_single → single)
      ↓
API returns updated UserModel
      ↓
kCurrentUserData updated + cached (SharedPreferences)
      ↓
setState() → _getQuestions() rebuilds (conditional questions update)
      ↓
PageController.nextPage()
```
