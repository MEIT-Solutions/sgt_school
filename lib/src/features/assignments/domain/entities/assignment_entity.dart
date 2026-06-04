import 'package:equatable/equatable.dart';

/// Assignment status.
enum AssignmentStatus {
  active,
  completed;

  static AssignmentStatus fromString(String value) {
    return AssignmentStatus.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => AssignmentStatus.active,
    );
  }
}

/// Represents a teacher's assignment for a class.
class AssignmentEntity extends Equatable {
  final String id;
  final String title;
  final String className;
  final String subject;
  final String dueDate;
  final AssignmentStatus status;
  final String? description;
  final int submittedCount;
  final int totalCount;

  const AssignmentEntity({
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

  bool get isActive => status == AssignmentStatus.active;
  double get submissionRate => totalCount > 0 ? submittedCount / totalCount : 0;

  @override
  List<Object?> get props => [
        id, title, className, subject, dueDate,
        status, description, submittedCount, totalCount,
      ];
}
