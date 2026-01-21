import 'package:tayseer/core/models/post_model.dart';

List<ReactionType> calculateTopReactions({
  required List<ReactionType> currentTopReactions,
  required ReactionType? oldReaction,
  required ReactionType? newReaction,
  required int newLikesCount,
}) {
  // 1️⃣ لو العدد الكلي صفر، يبقى أكيد مفيش أي تفاعلات
  if (newLikesCount <= 0) {
    return [];
  }

  final list = List<ReactionType>.from(currentTopReactions);

  // 2️⃣ حالة الإضافة أو التغيير (Adding / Changing)
  if (newReaction != null) {
    // شيله لو موجود عشان نحطه في الأول (تحديث الأولوية)
    list.remove(newReaction);

    // لو بغير الريأكشن (مثلا من Love لـ Haha)، شيل القديم
    if (oldReaction != null && oldReaction != newReaction) {
      list.remove(oldReaction);
    }

    // ضيف الجديد في الأول دائماً
    list.insert(0, newReaction);
  }
  // 3️⃣ حالة الإزالة (Removing) - هنا حل المشكلة
  else if (oldReaction != null) {
    // جرب امسح الريأكشن القديم
    list.remove(oldReaction);

    // 🚨 هنا اللوجيك الذكي:
    // لو القائمة فضيت، بس لسه فيه لايكات (newLikesCount > 0)
    // ده معناه إن اللايكات المتبقية دي أكيد من نفس نوع اللي أنا مسحته (أو غيره بس مش ظاهر).
    // في الحالة دي، رجع الريأكشن تاني عشان القائمة متبقاش فاضية والرقم شغال.
    if (list.isEmpty && newLikesCount > 0) {
      list.add(oldReaction);
    }
  }

  // 4️⃣ التأكد إننا مش عارضان أكتر من 3
  return list.take(3).toList();
}
