import 'package:equatable/equatable.dart';

/// Status of a school activity/event.
enum ActivityStatus {
  upcoming,
  completed;

  static ActivityStatus fromString(String value) {
    return ActivityStatus.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => ActivityStatus.upcoming,
    );
  }
}

/// Represents a school event or activity.
class ActivityEntity extends Equatable {
  final String id;
  final String title;
  final String date;
  final String location;
  final String? description;
  final ActivityStatus status;

  const ActivityEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    this.description,
    required this.status,
  });

  bool get isUpcoming => status == ActivityStatus.upcoming;

  @override
  List<Object?> get props => [id, title, date, location, description, status];
}
