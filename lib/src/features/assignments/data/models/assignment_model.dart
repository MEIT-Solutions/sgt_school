import '../../domain/entities/assignment_entity.dart';

/// DTO for [AssignmentEntity].
class AssignmentModel {
  final String id;
  final String title;
  final String className;
  final String subject;
  final String dueDate;
  final String status;
  final String? description;
  final int submittedCount;
  final int totalCount;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.className,
    required this.subject,
    required this.dueDate,
    required this.status,
    this.description,
    required this.submittedCount,
    required this.totalCount,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      className: (json['class_name'] ?? json['class']) as String? ?? '',
      subject: json['subject'] as String,
      dueDate: (json['due_date'] ?? json['dueDate']) as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      submittedCount: (json['submitted_count'] ?? json['submittedCount']) as int? ?? 0,
      totalCount: (json['total_count'] ?? json['totalCount']) as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'class_name': className,
        'subject': subject,
        'due_date': dueDate,
        'status': status,
        'description': description,
        'submitted_count': submittedCount,
        'total_count': totalCount,
      };

  AssignmentEntity toEntity() => AssignmentEntity(
        id: id,
        title: title,
        className: className,
        subject: subject,
        dueDate: dueDate,
        status: AssignmentStatus.fromString(status),
        description: description,
        submittedCount: submittedCount,
        totalCount: totalCount,
      );
}
