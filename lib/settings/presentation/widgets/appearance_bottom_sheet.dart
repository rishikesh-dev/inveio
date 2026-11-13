import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/settings/domain/entities/app_settings.dart';
import 'package:inveio/settings/presentation/cubit/theme_cubit.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bottom sheet listing the available theme options.
class AppearanceBottomSheet extends StatelessWidget {
  /// Creates an [AppearanceBottomSheet].
  const AppearanceBottomSheet({super.key});

  /// Shows the appearance bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AppearanceBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ThemeCubit, AppSettings>(
        builder: (context, settings) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.darkBorderSoft,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Appearance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how Inveio looks on this device.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 16),
                for (final mode in AppThemeMode.values)
                  _AppearanceOption(
                    mode: mode,
                    isSelected: settings.themeMode == mode,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({required this.mode, required this.isSelected});

  final AppThemeMode mode;
  final bool isSelected;

  IconData get _icon => switch (mode) {
    AppThemeMode.system => LucideIcons.smartphone,
    AppThemeMode.light => LucideIcons.sun,
    AppThemeMode.dark => LucideIcons.moon,
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(_icon, size: 20),
      title: Text(mode.label),
      trailing: isSelected
          ? const Icon(LucideIcons.check, color: AppColors.primary, size: 20)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        context.read<ThemeCubit>().setThemeMode(mode);
        Navigator.of(context).pop();
      },
    );
  }
}
