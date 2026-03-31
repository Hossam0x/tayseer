enum ChatRoomType {
  userAdvisor('user-advisor'),
  userUser('user-user');

  final String value;
  const ChatRoomType(this.value);

  @override
  String toString() => value;
}
