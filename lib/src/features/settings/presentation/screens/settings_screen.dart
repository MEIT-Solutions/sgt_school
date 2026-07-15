import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/settings/presentation/providers/settings_provider.dart';

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
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: cs.surfaceContainerLow,
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: cs.outlineVariant.withValues(alpha: 0.5),
          //     ),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(Icons.language, size: 20, color: cs.onSurfaceVariant),
          //           const SizedBox(width: 12),
          //           Text(
          //             'settings.language'.tr(),
          //             style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 12),
          //       SizedBox(
          //         width: double.infinity,
          //         child: SegmentedButton<String>(
          //           segments: [
          //             ButtonSegment(
          //               value: 'en',
          //               label: Text('English', style: const TextStyle(fontSize: 12)),
          //             ),
          //             ButtonSegment(
          //               value: 'my',
          //               label: Text('မြန်မာ', style: const TextStyle(fontSize: 12)),
          //             ),
          //           ],
          //           selected: {context.locale.languageCode},
          //           onSelectionChanged: (s) {
          //             context.setLocale(Locale(s.first));
          //           },
          //           showSelectedIcon: false,
          //           style: const ButtonStyle(
          //             visualDensity: VisualDensity.compact,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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
