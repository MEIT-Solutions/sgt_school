import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';

/// Profile screen with tabs (for students).
/// Settings icon in the top-left, logout icon in the top-right.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    final user = context.read<SessionProvider>().user;
    if (user != null && user.role == UserRole.student) {
      _tabController = TabController(length: 3, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final theme = context.theme;
    final tt = theme.textTheme;
    final session = context.read<SessionProvider>();
    final confirmed = await showAppDialog<bool>(
      context: context,
      child: Builder(
        builder: (dialogContext) => AlertDialog(
          title: Text(
            'auth.logout'.tr(),
            style: tt.titleMedium,
          ),
          content: Text(
            'settings.logout_confirm'.tr(),
            style: tt.bodySmall,
          ),
          actions: [
            TextButton(
              onPressed: () => popDialog(dialogContext, false),
              child: Text('settings.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => popDialog(dialogContext, true),
              child: Text('auth.logout'.tr()),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      session.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final session = context.watch<SessionProvider>();
    final user = session.user;
    if (user == null) return const SizedBox.shrink();

    final isStudent = user.role == UserRole.student;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: cs.primary,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Stack(
            children: [
              // ── Profile Info (centered) ──
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? CommonImage(
                            imageUrl: user.photoUrl!,
                            width: 80,
                            height: 80,
                            borderRadius: BorderRadius.circular(40),
                            placeholder: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: cs.onPrimary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: cs.onPrimary,
                                ),
                              ),
                            ),
                            errorWidget: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: cs.onPrimary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, size: 40, color: cs.onPrimary),
                            ),
                          )
                        : CircleAvatar(
                            radius: 40,
                            backgroundColor: cs.onPrimary.withValues(alpha: 0.2),
                            child: Icon(Icons.person, size: 40, color: cs.onPrimary),
                          ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      user.name,
                      style: tt.titleLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.ms),
                    if (isStudent)
                      Text(
                        '${user.grade} - ${user.section} • ${'profile.roll_no'.tr()} ${user.rollNo}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    SizedBox(height: AppSpacing.sm),
                    if (!isStudent)
                      Text(
                        user.role.name.toUpperCase(),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    SizedBox(height: AppSpacing.ml),
                  ],
                ),
              ),
              // ── Settings (top-left) ──
              Positioned(
                top: 0,
                left: AppSpacing.xs,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  color: cs.onPrimary,
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ),
              // ── Logout (top-right) ──
              Positioned(
                top: 0,
                right: AppSpacing.xs,
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  color: cs.onPrimary,
                  onPressed: () => _showLogoutDialog(context),
                ),
              ),
            ],
          ),
        ),
        bottom: isStudent && _tabController != null
            ? TabBar(
                controller: _tabController,
                labelColor: cs.onPrimary,
                unselectedLabelColor: cs.onPrimary.withValues(alpha: 0.6),
                indicatorColor: cs.onPrimary,
                tabs: [
                  Tab(text: 'profile.personal_info'.tr()),
                  Tab(text: 'profile.parent_info'.tr()),
                  Tab(text: 'profile.emergency'.tr()),
                ],
              )
            : null,
      ),
      body: isStudent && _tabController != null
          ? TabBarView(
              controller: _tabController,
              children: [
                _PersonalInfo(user: user),
                _ParentInfo(user: user),
                _EmergencyInfo(user: user),
              ],
            )
          : _PersonalInfo(user: user),
    );
  }
}

class _PersonalInfo extends StatelessWidget {
  final AppUser user;
  const _PersonalInfo({required this.user});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.role == UserRole.student) _InfoRow(icon: Icons.badge, label: 'profile.admission_no'.tr(), value: user.admissionNo ?? '-'),
          _InfoRow(icon: Icons.cake, label: 'profile.date_of_birth'.tr(), value: user.dateOfBirth ?? '-'),
          _InfoRow(icon: Icons.wc, label: 'profile.gender'.tr(), value: user.gender ?? '-'),
          _InfoRow(icon: Icons.phone, label: 'profile.phone'.tr(), value: user.phone),
          _InfoRow(icon: Icons.email, label: 'profile.email'.tr(), value: user.email ?? '-'),
          _InfoRow(icon: Icons.location_on, label: 'profile.address'.tr(), value: user.address ?? '-'),
          if (user.role == UserRole.student) ...[
            SizedBox(height: AppSpacing.md),
            Text('profile.class_info'.tr(), style: context.theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: AppSpacing.sm),
            _InfoRow(icon: Icons.school, label: 'profile.class_teacher'.tr(), value: user.classTeacher ?? '-'),
            _InfoRow(icon: Icons.groups, label: 'profile.section'.tr(), value: user.section ?? '-'),
            _InfoRow(icon: Icons.calendar_today, label: 'profile.academic_year'.tr(), value: user.academicYear ?? '-'),
          ],
          if (user.role == UserRole.teacher) ...[
            _InfoRow(icon: Icons.book, label: 'profile.subject'.tr(), value: user.subject ?? '-'),
            _InfoRow(icon: Icons.business, label: 'profile.department'.tr(), value: user.department ?? '-'),
          ],
        ],
      ),
    );
  }
}

class _ParentInfo extends StatelessWidget {
  final AppUser user;
  const _ParentInfo({required this.user});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(icon: Icons.person, label: 'profile.parent_name'.tr(), value: user.parentName ?? '-'),
          _InfoRow(icon: Icons.phone, label: 'profile.parent_phone'.tr(), value: user.parentPhone ?? '-'),
          _InfoRow(icon: Icons.family_restroom, label: 'profile.relation'.tr(), value: user.parentRelation ?? '-'),
        ],
      ),
    );
  }
}

class _EmergencyInfo extends StatelessWidget {
  final AppUser user;
  const _EmergencyInfo({required this.user});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(icon: Icons.person, label: 'profile.emergency_name'.tr(), value: user.emergencyName ?? '-'),
          _InfoRow(icon: Icons.phone, label: 'profile.emergency_contact'.tr(), value: user.emergencyContact ?? '-'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      child: Row(children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              SizedBox(height: AppSpacing.xxs),
              Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ]),
    );
  }
}
