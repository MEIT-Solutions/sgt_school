import 'package:equatable/equatable.dart';

/// Represents a school activity from the API.
class ActivityEntity extends Equatable {
  final String id;
  final String title;
  final String className;
  final String activityDate;
  final String state;
  final String dailyActivity;
  final bool mobileVisible;

  const ActivityEntity({
    required this.id,
    required this.title,
    required this.className,
    required this.activityDate,
    required this.state,
    required this.dailyActivity,
    required this.mobileVisible,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        className,
        activityDate,
        state,
        dailyActivity,
        mobileVisible,
      ];
}
