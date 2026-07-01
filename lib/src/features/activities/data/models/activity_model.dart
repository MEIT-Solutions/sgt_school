import '../../domain/entities/activity_entity.dart';

/// DTO for [ActivityAttachment].
class ActivityAttachmentModel {
  final String id;
  final String title;
  final String fileName;
  final String fileUrl;

  const ActivityAttachmentModel({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileUrl,
  });

  /// Parses an exam_paper or grade_report object.
  ///
  /// These objects have `file_name` and `file_url` but no `id` or `title`,
  /// so we derive [id] from the activity id and [title] from [label].
  factory ActivityAttachmentModel.fromFileJson(
    Map<String, dynamic> json, {
    required String id,
    required String label,
  }) {
    return ActivityAttachmentModel(
      id: id,
      title: label,
      fileName: json['file_name'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
    );
  }

  /// Parses a document object from the `documents` list.
  factory ActivityAttachmentModel.fromDocumentJson(Map<String, dynamic> json) {
    return ActivityAttachmentModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
    );
  }

  ActivityAttachment toEntity() => ActivityAttachment(
        id: id,
        title: title,
        fileName: fileName,
        fileUrl: fileUrl,
      );
}

/// DTO for [ActivityEntity].
class ActivityModel {
  final String id;
  final String title;
  final String className;
  final String activityDate;
  final String state;
  final String dailyActivity;
  final bool mobileVisible;
  final ActivityAttachmentModel? examPaper;
  final ActivityAttachmentModel? gradeReport;
  final List<ActivityAttachmentModel> documents;

  const ActivityModel({
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

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final activityId = (json['id'] ?? '').toString();

    // Parse exam_paper (single file, nullable).
    ActivityAttachmentModel? examPaper;
    final examPaperJson = json['exam_paper'];
    if (examPaperJson is Map<String, dynamic> &&
        (examPaperJson['file_url'] as String?)?.isNotEmpty == true) {
      examPaper = ActivityAttachmentModel.fromFileJson(
        examPaperJson,
        id: activityId,
        label: 'Exam Paper',
      );
    }

    // Parse grade_report (single file, nullable).
    ActivityAttachmentModel? gradeReport;
    final gradeReportJson = json['grade_report'];
    if (gradeReportJson is Map<String, dynamic> &&
        (gradeReportJson['file_url'] as String?)?.isNotEmpty == true) {
      gradeReport = ActivityAttachmentModel.fromFileJson(
        gradeReportJson,
        id: activityId,
        label: 'Grade Report',
      );
    }

    // Parse documents (list, can be empty).
    final docsJson = json['documents'] as List? ?? [];
    final documents = docsJson
        .whereType<Map<String, dynamic>>()
        .where((d) => (d['file_url'] as String?)?.isNotEmpty == true)
        .map((d) => ActivityAttachmentModel.fromDocumentJson(d))
        .toList();

    return ActivityModel(
      id: activityId,
      title: json['title'] as String? ?? '',
      className: json['class'] as String? ?? '',
      activityDate: json['activity_date'] as String? ?? '',
      state: json['state'] as String? ?? '',
      dailyActivity: json['daily_activity'] as String? ?? '',
      mobileVisible: json['mobile_visible'] as bool? ?? false,
      examPaper: examPaper,
      gradeReport: gradeReport,
      documents: documents,
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
        examPaper: examPaper?.toEntity(),
        gradeReport: gradeReport?.toEntity(),
        documents: documents.map((d) => d.toEntity()).toList(),
      );
}
