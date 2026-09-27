import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inveio/profile/presentation/widgets/settings_tile.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const AppBarWidget(title: 'Security', centerTitle: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 10,
                children: [
                  SettingsTile(
                    onTap: () {},
                    icon: LucideIcons.lockKeyhole,
                    title: 'App Lock',
                    subtitle: 'Use biometrics or passcode to protect your app',
                    borderRadius: 12,
                  ),
                  SettingsTile(
                    onTap: () {},
                    icon: LucideIcons.fingerprint,
                    title: 'Biometric Authentication',
                    subtitle: 'Use Face ID/Touch ID',
                    borderRadius: 12,
                    contentPadding: const EdgeInsets.only(right: 7, left: 12),
                    trailingWidget: Switch(value: true, onChanged: (value) {}),
                  ),
                  SettingsTile(
                    onTap: () {
                      context.pushNamed(RouterConstants.changePasswordScreen);
                    },
                    icon: LucideIcons.keyRound,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    borderRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
