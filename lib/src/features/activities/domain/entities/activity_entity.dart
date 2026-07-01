import 'package:equatable/equatable.dart';

/// Represents a downloadable file attachment on an activity.
class ActivityAttachment extends Equatable {
  final String id;
  final String title;
  final String fileName;
  final String fileUrl;

  const ActivityAttachment({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileUrl,
  });

  @override
  List<Object?> get props => [id, title, fileName, fileUrl];
}

/// Represents a school activity from the API.
class ActivityEntity extends Equatable {
  final String id;
  final String title;
  final String className;
  final String activityDate;
  final String state;
  final String dailyActivity;
  final bool mobileVisible;
  final ActivityAttachment? examPaper;
  final ActivityAttachment? gradeReport;
  final List<ActivityAttachment> documents;

  const ActivityEntity({
    required this.id,
    required this.title,
    required this.className,
    required this.activityDate,
    required this.state,
    required this.dailyActivity,
    required this.mobileVisible,
    this.examPaper,
    this.gradeReport,
    this.documents = const [],
  });

  /// Whether this activity has any downloadable attachments.
  bool get hasAttachments =>
      examPaper != null || gradeReport != null || documents.isNotEmpty;

  /// Total number of downloadable attachments.
  int get attachmentCount =>
      (examPaper != null ? 1 : 0) +
      (gradeReport != null ? 1 : 0) +
      documents.length;

  @override
  List<Object?> get props => [
        id,
        title,
        className,
        activityDate,
        state,
        dailyActivity,
        mobileVisible,
        examPaper,
        gradeReport,
        documents,
      ];
}
