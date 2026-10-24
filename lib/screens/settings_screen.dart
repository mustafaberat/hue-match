/// Ayarlar (§9, MOBILE_APP_RULES §1.1).
library;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../components/buttons.dart';
import '../components/segmented.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';
import 'how_to_play_screen.dart';
import '../components/l10n_format.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({this.versionOverride, super.key});

  /// Ekran görüntüsünde platform kanalı olmadan sürüm.
  final String? versionOverride;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _version = widget.versionOverride;
    if (_version == null) _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      // Sürüm okunamazsa satır boş kalır.
    }
  }

  Future<void> _pickLanguage() async {
    final settings = AppScope.of(context).settings;
    final code = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final entry in AppLanguages.nativeNames.entries)
              ListTile(
                title: Text(entry.value, style: AppText.bodyStrong),
                trailing: entry.key == settings.languageCode
                    ? Icon(Icons.check_rounded, color: AppColors.accent)
                    : null,
                onTap: () => Navigator.of(context).pop(entry.key),
              ),
          ],
        ),
      ),
    );
    if (code != null) await settings.setLanguage(code);
  }

  Future<void> _openPrivacy() async {
    try {
      await launchUrl(
        Uri.parse(AppIdentity.privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Tarayıcı açılamazsa sessiz geç.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppScope.of(context).settings;

    return ThemedScaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: ListenableBuilder(
              listenable: settings,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.xxxl,
                ),
                children: [
                  Row(
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: l10n.back,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Text(
                        l10n.settings,
                        style: AppText.onSky(AppText.heading),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _Section(
                    title: l10n.sectionGame,
                    children: [
                      _Row(
                        icon: Icons.timer_outlined,
                        title: l10n.settingsRevealTime,
                        subtitle: l10n.settingsRevealTimeHint,
                        bottom: Segmented<int>(
                          options: {
                            for (final s in GameRules.revealSecondsOptions)
                              s: l10n.secondsShort(s),
                          },
                          selected: settings.revealSeconds,
                          onChanged: settings.setRevealSeconds,
                        ),
                      ),
                      _SwitchRow(
                        icon: Icons.tag_rounded,
                        title: l10n.settingsShowValues,
                        subtitle: l10n.settingsShowValuesHint,
                        value: settings.showValues,
                        onChanged: settings.setShowValues,
                      ),
                      _SwitchRow(
                        icon: Icons.shuffle_rounded,
                        title: l10n.settingsRandomStart,
                        subtitle: l10n.settingsRandomStartHint,
                        value: settings.randomStart,
                        onChanged: settings.setRandomStart,
                      ),
                      _SwitchRow(
                        icon: Icons.visibility_outlined,
                        title: l10n.settingsColorBlind,
                        subtitle: l10n.settingsColorBlindHint,
                        value: settings.colorBlindMode,
                        onChanged: settings.setColorBlindMode,
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.sectionGeneral,
                    children: [
                      _Row(
                        icon: Icons.translate_rounded,
                        title: l10n.settingsLanguage,
                        trailing: _Value(
                          text:
                              AppLanguages.nativeNames[settings.languageCode] ??
                              '',
                          chevron: true,
                        ),
                        onTap: _pickLanguage,
                      ),
                    ],
                  ),
                  _Section(
                    title: l10n.sectionAbout,
                    children: [
                      _Row(
                        icon: Icons.help_outline_rounded,
                        title: l10n.howToPlay,
                        trailing: const _Chevron(),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            fullscreenDialog: true,
                            builder: (_) => const HowToPlayScreen(),
                          ),
                        ),
                      ),
                      _Row(
                        icon: Icons.shield_outlined,
                        title: l10n.settingsPrivacy,
                        trailing: Icon(
                          Icons.open_in_new_rounded,
                          size: AppSizes.iconSmall,
                          color: AppColors.textMuted,
                        ),
                        onTap: _openPrivacy,
                      ),
                      _Row(
                        icon: Icons.info_outline_rounded,
                        title: l10n.settingsVersion,
                        trailing: _Value(text: _version ?? ''),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '${AppIdentity.appName} · ${AppIdentity.developer}',
                    textAlign: TextAlign.center,
                    style: AppText.onSky(AppText.caption, muted: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: SkyCaption(
              title.upperFor(context),
              textAlign: TextAlign.start,
            ),
          ),
          DecoratedBox(
            decoration: appCardDecoration(),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: AppSizes.settingsDividerIndent,
                      color: AppColors.outline,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSizes.settingsRowMinHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: AppSizes.icon, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppText.bodyStrong),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle!,
                        style: AppText.small.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    if (bottom != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      bottom!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Row(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({required this.text, this.chevron = false});

  final String text;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: AppText.small),
        if (chevron) ...[
          const SizedBox(width: AppSpacing.xs),
          const _Chevron(),
        ],
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.chevron_right_rounded, color: AppColors.textMuted);
}
