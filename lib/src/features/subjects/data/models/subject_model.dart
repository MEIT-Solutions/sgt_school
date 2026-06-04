import '../../domain/entities/subject_entity.dart';

/// DTO for [SubjectEntity] — handles JSON serialization.
class SubjectModel {
  final String id;
  final String name;
  final String teacher;
  final String icon;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.teacher,
    required this.icon,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      teacher: json['teacher'] as String,
      icon: json['icon'] as String? ?? 'book',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'teacher': teacher,
        'icon': icon,
      };

  SubjectEntity toEntity() => SubjectEntity(
        id: id,
        name: name,
        teacher: teacher,
        icon: icon,
      );
}
