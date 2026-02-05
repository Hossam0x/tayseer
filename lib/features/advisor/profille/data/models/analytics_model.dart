import 'package:equatable/equatable.dart';

class AnalyticsModel extends Equatable {
  final AnalyticsOverview overview;
  final List<ChartData> chart;

  const AnalyticsModel({required this.overview, required this.chart});

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final overviewData = json['overview'] as Map<String, dynamic>;
    final chartData = json['chart'] as List<dynamic>;

    return AnalyticsModel(
      overview: AnalyticsOverview.fromJson(overviewData),
      chart: chartData
          .map((item) => ChartData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [overview, chart];
}

class AnalyticsOverview extends Equatable {
  final int views;
  final int visits;
  final int newFollowers;
  final int interactions;

  const AnalyticsOverview({
    required this.views,
    required this.visits,
    required this.newFollowers,
    required this.interactions,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      views: json['views'] ?? 0,
      visits: json['visitors'] ?? 0,
      newFollowers: json['followers'] ?? 0,
      interactions: json['interactions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'views': views,
    'visitors': visits,
    'followers': newFollowers,
    'interactions': interactions,
  };

  @override
  List<Object?> get props => [views, visits, newFollowers, interactions];
}

class ChartData extends Equatable {
  final DateTime date;
  final int views;
  final int visits;
  final int followers;
  final int interactions;

  const ChartData({
    required this.date,
    required this.views,
    required this.visits,
    required this.followers,
    required this.interactions,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      date: DateTime.parse(json['date']),
      views: json['views'] ?? 0,
      visits: json['visitors'] ?? 0,
      followers: json['followers'] ?? 0,
      interactions: json['interactions'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [date, views, visits, followers, interactions];
}
