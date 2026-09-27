import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UpgradeBanner extends StatelessWidget {
  const UpgradeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF9EFF3F).withValues(alpha: .25),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101610), Color(0xFF182316), Color(0xFF314D1E)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Green ambient glow
            Positioned(
              right: -70,
              bottom: -100,
              child: Container(
                width: 300,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9EFF3F).withValues(alpha: .22),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: const SizedBox(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: .28),
                    ),
                    child: const Icon(
                      LucideIcons.crown,
                      size: 25,
                      color: Color(0xFF9EFF3F),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Text
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade to Pro',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Unlock advanced features\nand grow your business.',
                          style: TextStyle(
                            fontSize: 10.5,
                            height: 1.35,
                            color: Color(0xFF9EA59D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Button
                  IntrinsicWidth(
                    child: NeonButton(
                      height: 40,
                      label: 'Upgrade',
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () {},
                      icon: LucideIcons.chevronRight,
                      borderRadius: BorderRadius.circular(100),
                      padding: const EdgeInsets.only(left: 15, right: 10),
                      iconAlignment: IconAlignment.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
