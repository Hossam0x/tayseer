/// البيانات اللي بترجع من السيرفر بعد إنشاء البوست
class CreatedPostData {
  final String id;
  final String userId;
  final String categoryId;
  final String content;
  final String postType;
  final String userRef;
  final DateTime createdAt;

  const CreatedPostData({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.content,
    required this.postType,
    required this.userRef,
    required this.createdAt,
  });

  factory CreatedPostData.fromJson(Map<String, dynamic> json) {
    return CreatedPostData(
      id: json['_id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      postType: json['postType'] as String? ?? 'post',
      userRef: json['userRef'] as String? ?? 'Advisor',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
