import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';

/// Settings screen with theme mode, language, app logo, and version info.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('settings.title'.tr()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ─── App Branding ───
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                // App logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icons/app_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.school,
                        size: 40,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'SGT International School',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Shan Golden Triangle International School',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'v${settings.appVersion} (${settings.buildNumber})',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── Appearance Section ───
          _SectionHeader(title: 'settings.appearance'.tr()),
          const SizedBox(height: 8),

          // Theme Mode
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette_outlined, size: 20, color: cs.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(
                      'settings.theme_mode'.tr(),
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.settings_suggest, size: 18),
                        label: Text('settings.system'.tr(), style: const TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode, size: 18),
                        label: Text('settings.light'.tr(), style: const TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode, size: 18),
                        label: Text('settings.dark'.tr(), style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) => settings.setThemeMode(s.first),
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Language
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language, size: 20, color: cs.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(
                      'settings.language'.tr(),
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'en',
                        label: Text('English', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: 'my',
                        label: Text('မြန်မာ', style: TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: 'th',
                        label: Text('ไทย', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    selected: {context.locale.languageCode},
                    onSelectionChanged: (s) {
                      context.setLocale(Locale(s.first));
                    },
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Legal Section ───
          _SectionHeader(title: 'settings.legal'.tr()),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'settings.privacy_policy'.tr(),
            onTap: () => UrlLauncherService.instance.launch(
              'https://app.sgt-odoo.com/privacy',
            ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: 'settings.terms_of_service'.tr(),
            onTap: () => UrlLauncherService.instance.launch(
              'https://app.sgt-odoo.com/terms',
            ),
          ),

          const SizedBox(height: 24),

          // ─── Support Section ───
          _SectionHeader(title: 'settings.support'.tr()),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.school_outlined,
            label: 'settings.contact_school'.tr(),
            onTap: () => UrlLauncherService.instance.launch(
              'https://app.sgt-odoo.com/contact',
            ),
          ),

          const SizedBox(height: 24),

          // ─── Account Section ───
          _SectionHeader(title: 'settings.account'.tr()),
          const SizedBox(height: 8),
          _DeleteAccountTile(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.theme.colorScheme.primary,
      ),
    );
  }
}

/// A tappable settings row with icon, label, and chevron.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Destructive "Delete Account" tile with a confirmation dialog
/// that requires the user to type "DELETE" to proceed.
class _DeleteAccountTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    return InkWell(
      onTap: () => _showDeleteDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.delete_forever_outlined, size: 20, color: cs.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'settings.delete_account'.tr(),
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.error,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: cs.error),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext ctx) async {
    final controller = TextEditingController();
    final session = ctx.read<SessionProvider>();

    final confirmed = await showAppDialog<bool>(
      context: ctx,
      child: Builder(
        builder: (dialogContext) {
          final cs = dialogContext.theme.colorScheme;
          final tt = dialogContext.theme.textTheme;
          return StatefulBuilder(
            builder: (context, setState) {
              final isValid = controller.text.trim().toUpperCase() == 'DELETE';
              return AlertDialog(
                icon: Icon(Icons.warning_amber_rounded, size: 48, color: cs.error),
                title: Text(
                  'settings.delete_account_title'.tr(),
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'settings.delete_account_warning'.tr(),
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'settings.delete_account_confirm'.tr(),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => popDialog(dialogContext, false),
                    child: Text('settings.cancel'.tr()),
                  ),
                  FilledButton(
                    onPressed: isValid ? () => popDialog(dialogContext, true) : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                    ),
                    child: Text('settings.delete'.tr()),
                  ),
                ],
              );
            },
          );
        },
      ),
    );

    if (confirmed == true) {
      if (!ctx.mounted) return;
      // Clear session and show success toast
      showToast(ctx, message: 'settings.delete_account_success'.tr());
      session.logout();
    }
  }
}
