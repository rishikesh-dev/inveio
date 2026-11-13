import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/shared/presentation/widgets/user_avatar_widget.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:inveio/shared/utils/extensions/extensions.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Displays the user's avatar, name, and membership status badge.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  /// The user whose profile information is displayed.
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).cardColor,
          ),
          child: Row(
            children: [
              UserAvatarWidget(
                userName: user.name,
                radius: 35,
              ).withPadding(const EdgeInsets.only(right: 15)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      user.email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(),
                    ).withPadding(const EdgeInsets.only(bottom: 7)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      user.isPro ? 'PREMIUM MEMBER' : 'FREE MEMBER',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Flexible(
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.chevronRight),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ],
    );
    // return Column(
    //   children: [
    //     Stack(
    //       alignment: Alignment.bottomRight,
    //       children: [
    //         Container(
    //           width: 126,
    //           height: 126,
    //           padding: const EdgeInsets.all(5),
    //           decoration: BoxDecoration(
    //             shape: BoxShape.circle,
    //             border: Border.all(
    //               color: AppColors.primary.withValues(alpha: 0.3),
    //               width: 4,
    //             ),
    //           ),
    //           child: UserAvatarWidget(
    //             radius: 56,
    //             userName: user.name,
    //             netWorkImage: user.photoUrl ?? '',
    //           ),
    //         ),
    //         Container(
    //           width: 28,
    //           height: 28,
    //           decoration: BoxDecoration(
    //             color: AppColors.primary,
    //             shape: BoxShape.circle,
    //             border: Border.all(color: AppColors.darkBg, width: 3),
    //           ),
    //         ),
    //       ],
    //     ),
    //     const SizedBox(height: 18),
    //     Text(
    //       user.name.isEmpty ? 'Inveio User' : user.name,
    //       textAlign: TextAlign.center,
    //       style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    //         color: AppColors.darkTextPrimary,
    //         fontWeight: FontWeight.w900,
    //       ),
    //     ),
    //     const SizedBox(height: 10),
    //     Container(
    //       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    //       decoration: BoxDecoration(
    //         color: AppColors.primary.withValues(alpha: 0.12),
    //         border: Border.all(
    //           color: AppColors.primary.withValues(alpha: 0.35),
    //         ),
    //         borderRadius: BorderRadius.circular(100),
    //       ),
    //       child: Text(
    //         user.isPro ? 'PREMIUM MEMBER' : 'FREE MEMBER',
    //         style: const TextStyle(
    //           color: AppColors.primaryLight,
    //           fontSize: 11,
    //           fontWeight: FontWeight.w900,
    //           letterSpacing: 0,
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
