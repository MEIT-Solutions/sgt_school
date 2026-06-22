import '../../domain/entities/activity_entity.dart';

/// DTO for [ActivityEntity].
class ActivityModel {
  final String id;
  final String title;
  final String className;
  final String activityDate;
  final String state;
  final String dailyActivity;
  final bool mobileVisible;

  const ActivityModel({
    required this.id,
    required this.title,
    required this.className,
    required this.activityDate,
    required this.state,
    required this.dailyActivity,
    required this.mobileVisible,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      className: json['class'] as String? ?? '',
      activityDate: json['activity_date'] as String? ?? '',
      state: json['state'] as String? ?? '',
      dailyActivity: json['daily_activity'] as String? ?? '',
      mobileVisible: json['mobile_visible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'class': className,
        'activity_date': activityDate,
        'state': state,
        'daily_activity': dailyActivity,
        'mobile_visible': mobileVisible,
      };

  ActivityEntity toEntity() => ActivityEntity(
        id: id,
        title: title,
        className: className,
        activityDate: activityDate,
        state: state,
        dailyActivity: dailyActivity,
        mobileVisible: mobileVisible,
      );
}
