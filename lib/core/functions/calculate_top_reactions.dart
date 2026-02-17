import 'package:tayseer/core/models/post_model.dart';

/// ✅ حساب topReactions بناءً على التغيير في الـ reaction
/// يدعم البنية الجديدة: List<TopReactionModel> مع count لكل نوع
List<TopReactionModel> calculateTopReactions({
  required List<TopReactionModel> currentTopReactions,
  required ReactionType? oldReaction,
  required ReactionType? newReaction,
  required int newLikesCount,
}) {
  // 1️⃣ لو العدد الكلي صفر، يبقى أكيد مفيش أي تفاعلات
  if (newLikesCount <= 0) {
    return [];
  }

  final updatedList = List<TopReactionModel>.from(currentTopReactions);

  // 2️⃣ معالجة الـ reaction القديم (إن وُجد)
  if (oldReaction != null) {
    final oldIndex = updatedList.indexWhere((r) => r.type == oldReaction);
    if (oldIndex != -1) {
      final oldReactionModel = updatedList[oldIndex];
      if (oldReactionModel.count > 1) {
        // ✅ لو في ناس تانية مستخدماه: ننقص العدد
        updatedList[oldIndex] = oldReactionModel.copyWith(
          count: oldReactionModel.count - 1,
        );
      } else {
        // ❌ لو هو الوحيد: نحذف النوع ده من القائمة
        updatedList.removeAt(oldIndex);
      }
    }
  }

  // 3️⃣ معالجة الـ reaction الجديد (إن وُجد)
  if (newReaction != null) {
    final newIndex = updatedList.indexWhere((r) => r.type == newReaction);
    if (newIndex != -1) {
      // ✅ النوع موجود: نزود العدد
      final existingReaction = updatedList[newIndex];
      updatedList[newIndex] = existingReaction.copyWith(
        count: existingReaction.count + 1,
      );
    } else {
      // ✅ النوع مش موجود: نضيفه
      updatedList.add(TopReactionModel(type: newReaction, count: 1));
    }
  }

  // 4️⃣ ترتيب القائمة بناءً على العدد (الأكثر أولاً) وأخذ أول 3
  updatedList.sort((a, b) => b.count.compareTo(a.count));
  return updatedList.take(3).toList();
}
