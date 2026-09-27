import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.image,
    this.onTap,
  });

  final ImageProvider? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              backgroundImage: image,
              child: image == null
                  ? const Icon(
                      Icons.person,
                      size: 56,
                    )
                  : null,
            ),

            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          'Profile Photo',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 6),

        Text(
          'Tap to change your profile photo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: .7),
              ),
        ),
      ],
    );
  }
}
