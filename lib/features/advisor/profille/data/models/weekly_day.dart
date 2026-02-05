class CategoryWeeklyData {
  final List<int> weeksData;

  CategoryWeeklyData({required this.weeksData});
}

class WeeklyData {
  final int views;
  final int visits;
  final int followers;
  final int interactions;

  WeeklyData({
    required this.views,
    required this.visits,
    required this.followers,
    required this.interactions,
  });
}
