import '../../domain/entities/activity_entity.dart';

/// DTO for [ActivityEntity].
class ActivityModel {
  final String id;
  final String title;
  final String date;
  final String location;
  final String? description;
  final String status;

  const ActivityModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    this.description,
    required this.status,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      location: json['location'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'location': location,
        'description': description,
        'status': status,
      };

  ActivityEntity toEntity() => ActivityEntity(
        id: id,
        title: title,
        date: date,
        location: location,
        description: description,
        status: ActivityStatus.fromString(status),
      );
}
