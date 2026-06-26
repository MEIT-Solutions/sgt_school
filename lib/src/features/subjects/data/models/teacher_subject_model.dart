import '../../domain/entities/teacher_subject_entity.dart';

/// DTO for [TeacherSubjectEntity] — handles JSON serialization.
class TeacherSubjectModel {
  final String id;
  final String name;
  final String subjectCode;
  final String? description;

  const TeacherSubjectModel({
    required this.id,
    required this.name,
    required this.subjectCode,
    this.description,
  });

  factory TeacherSubjectModel.fromJson(Map<String, dynamic> json) {
    return TeacherSubjectModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      subjectCode: (json['subject_code'] ?? '').toString(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subject_code': subjectCode,
        'description': description,
      };

  TeacherSubjectEntity toEntity() => TeacherSubjectEntity(
        id: id,
        name: name,
        subjectCode: subjectCode,
        description: description,
      );
}
