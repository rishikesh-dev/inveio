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
