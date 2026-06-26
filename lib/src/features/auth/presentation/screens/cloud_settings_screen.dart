import 'package:sgt_school/src/imports/core_imports.dart';

/// Allows the user to switch the API base URL between Dev, Production, or Custom.
class CloudSettingsScreen extends StatefulWidget {
  const CloudSettingsScreen({super.key});

  @override
  State<CloudSettingsScreen> createState() => _CloudSettingsScreenState();
}

enum _UrlMode { dev, prod, custom }

class _CloudSettingsScreenState extends State<CloudSettingsScreen> {
  _UrlMode _mode = _UrlMode.dev;
  final _customController = TextEditingController();
  bool _isSaving = false;
  String _currentUrl = AppConfig.devBaseUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  Future<void> _loadCurrentUrl() async {
    final url = await AppConfig.getStoredBaseUrl();
    if (!mounted) return;
    setState(() {
      _currentUrl = url;
      if (url == AppConfig.devBaseUrl) {
        _mode = _UrlMode.dev;
      } else if (url == AppConfig.prodBaseUrl) {
        _mode = _UrlMode.prod;
      } else {
        _mode = _UrlMode.custom;
        _customController.text = url;
      }
    });
  }

  String get _selectedUrl {
    switch (_mode) {
      case _UrlMode.dev:
        return AppConfig.devBaseUrl;
      case _UrlMode.prod:
        return AppConfig.prodBaseUrl;
      case _UrlMode.custom:
        return _customController.text.trim();
    }
  }

  Future<void> _save() async {
    final url = _selectedUrl;
    if (url.isEmpty) {
      showToast(context, message: 'cloud.url_required'.tr(), status: 'error');
      return;
    }

    setState(() => _isSaving = true);
    await AppConfig.updateBaseUrl(url);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _currentUrl = url;
    });

    showToast(context, message: 'cloud.saved_success'.tr());
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppTopBar(title: 'cloud.title'.tr()),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Current URL ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'cloud.current_url'.tr(),
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentUrl,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Mode Selection ──
          Text(
            'cloud.select_mode'.tr(),
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildRadioTile(
            mode: _UrlMode.dev,
            icon: Icons.bug_report_outlined,
            title: 'cloud.dev_mode'.tr(),
            subtitle: AppConfig.devBaseUrl,
            color: const Color(0xFFFFA726),
          ),

          const SizedBox(height: 8),

          _buildRadioTile(
            mode: _UrlMode.prod,
            icon: Icons.rocket_launch_outlined,
            title: 'cloud.prod_mode'.tr(),
            subtitle: AppConfig.prodBaseUrl,
            color: const Color(0xFF4CAF50),
          ),

          const SizedBox(height: 8),

          _buildRadioTile(
            mode: _UrlMode.custom,
            icon: Icons.edit_outlined,
            title: 'cloud.custom_mode'.tr(),
            subtitle: 'cloud.custom_desc'.tr(),
            color: const Color(0xFF42A5F5),
          ),

          // ── Custom URL Field ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _mode == _UrlMode.custom
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppTextField(
                controller: _customController,
                label: 'cloud.base_url_label'.tr(),
                hint: 'cloud.base_url_hint'.tr(),
                prefixIcon: const Icon(Icons.link),
                keyboardType: TextInputType.url,
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),

          const SizedBox(height: 32),

          // ── Save Button ──
          AppButton(
            label: 'cloud.save'.tr(),
            onPressed: _save,
            variant: ButtonVariant.primary,
            height: ButtonSize.large,
            isLoading: _isSaving,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile({
    required _UrlMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final isSelected = _mode == mode;

    return InkWell(
      onTap: () => setState(() => _mode = mode),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : cs.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontFamily: mode != _UrlMode.custom ? 'monospace' : null,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // ignore: deprecated_member_use
            Radio<_UrlMode>(
              value: mode,
              // ignore: deprecated_member_use
              groupValue: _mode,
              activeColor: color,
              // ignore: deprecated_member_use
              onChanged: (v) => setState(() => _mode = v!),
            ),
          ],
        ),
      ),
    );
  }
}
