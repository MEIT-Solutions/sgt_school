import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/notification_provider.dart';

/// Notification list screen accessed from the bell icon.
class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = context.read<SessionProvider>().user?.role.name ?? 'student';
      context.read<NotificationProvider>().loadNotifications(role);
    });
  }

  static const _categoryIcons = {
    'exam': Icons.quiz, 'event': Icons.event, 'fee': Icons.payment,
    'notice': Icons.campaign, 'assignment': Icons.assignment,
    'attendance': Icons.calendar_today,
  };
  static const _categoryColors = {
    'exam': Color(0xFFEF5350), 'event': Color(0xFF5C6BC0), 'fee': Color(0xFFFF7043),
    'notice': Color(0xFFFFA726), 'assignment': Color(0xFF42A5F5),
    'attendance': Color(0xFF66BB6A),
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppTopBar(title: 'notices.title'.tr()),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? AppErrorWidget(
                  message: provider.error,
                  onRetry: () {
                    final role = context.read<SessionProvider>().user?.role.name ?? 'student';
                    context.read<NotificationProvider>().loadNotifications(role);
                  },
                )
              : ListView.separated(
              padding: const EdgeInsets.all(16), itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = provider.notifications[i];
                final icon = _categoryIcons[n.category.name] ?? Icons.info;
                final color = _categoryColors[n.category.name] ?? const Color(0xFF42A5F5);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(n.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                        Text(n.createdAt, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ]),
                      const SizedBox(height: 4),
                      Text(n.body, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ])),
                  ]),
                );
              },
            ),
    );
  }
}
