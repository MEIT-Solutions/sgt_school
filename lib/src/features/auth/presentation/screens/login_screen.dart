import 'package:package_info_plus/package_info_plus.dart';
import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _autoValidate = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = 'v${info.version} (${info.buildNumber})');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _autoValidate = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthProvider>().login(
          context: context,
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthProvider p) => p.isLoading);
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primaryContainer.withValues(alpha: 0.15),
              cs.secondaryContainer.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Settings Menu (top-right) ──
              Positioned(
                top: 8,
                right: 0,
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'settings') {
                      context.push(AppRoutes.settings);
                    } else if (value == 'cloud') {
                      context.push(AppRoutes.cloudSettings);
                    }
                  },
                  itemBuilder: (_) => [
                    if (kDebugMode)
                      PopupMenuItem(
                        value: 'cloud',
                        child: Row(
                          children: [
                            Icon(Icons.cloud_outlined, size: 20, color: cs.onSurface),
                            const SizedBox(width: 12),
                            Text('cloud.title'.tr()),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, size: 20, color: cs.onSurface),
                          const SizedBox(width: 12),
                          Text('settings.title'.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Main Content ──
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),

                      // Premium App Logo Frame
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(
                                'assets/icons/app_logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.school_rounded,
                                  size: 34,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Title & Subtitle
                      Text(
                        'auth.login_title'.tr(),
                        style: tt.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'auth.login_subtitle'.tr(),
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Form Container Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.015),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              // Phone number field
                              AppTextField(
                                controller: _phoneController,
                                enabled: !isLoading,
                                label: 'auth.phone_label'.tr(),
                                hint: 'auth.phone_hint'.tr(),
                                prefixIcon: const Icon(Icons.phone_outlined),
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (AppUtils.isBlank(v)) {
                                    return 'auth.phone_required'.tr();
                                  }
                                  if (!AppUtils.isPhoneNumber(v!)) {
                                    return 'auth.phone_invalid'.tr();
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Password field
                              AppTextField(
                                controller: _passwordController,
                                enabled: !isLoading,
                                label: 'auth.password_label'.tr(),
                                hint: 'auth.password_hint'.tr(),
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (v) {
                                  if (AppUtils.isBlank(v)) {
                                    return 'auth.password_required'.tr();
                                  }
                                  if (v!.length < 5) {
                                    return 'auth.password_min_length'.tr();
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 32),

                              // AppButton integration
                              AppButton(
                                label: 'auth.log_in'.tr(),
                                onPressed: _handleLogin,
                                variant: ButtonVariant.primary,
                                height: ButtonSize.large,
                                isLoading: isLoading,
                                isFullWidth: true,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Version number
                      if (_version.isNotEmpty)
                        Text(
                          _version,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Legal links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => UrlLauncherService.instance.launch(
                              'https://app.sgt-odoo.com/privacy',
                            ),
                            child: Text(
                              'settings.privacy_policy'.tr(),
                              style: tt.labelSmall?.copyWith(
                                color: cs.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '•',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => UrlLauncherService.instance.launch(
                              'https://app.sgt-odoo.com/terms',
                            ),
                            child: Text(
                              'settings.terms_of_service'.tr(),
                              style: tt.labelSmall?.copyWith(
                                color: cs.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
