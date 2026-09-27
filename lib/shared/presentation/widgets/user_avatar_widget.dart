import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A circular avatar that displays a network image or the user's initial.
class UserAvatarWidget extends StatelessWidget {
  /// Creates a [UserAvatarWidget] with optional network image and user name.
  const UserAvatarWidget({
    super.key,
    this.netWorkImage = '',
    this.userName = '',
    this.defaultImage = '',
    this.radius = 20,
  });

  /// URL of the user's network profile image.
  final String netWorkImage;

  /// User's display name (first letter used as fallback).
  final String userName;

  /// Fallback default image path (currently unused).
  final String defaultImage;

  /// Radius of the avatar circle (default: 20).
  final double radius;

  @override
  /// Builds the avatar showing a network image or the user's initial.
  Widget build(BuildContext context) {
    final initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : '?';
    if (netWorkImage.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        child: Text(
          initial,
          style: TextStyle(fontSize: radius * 0.8, fontWeight: FontWeight.bold),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CachedNetworkImage(
        imageUrl: netWorkImage.trim(),
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(radius: radius, backgroundImage: imageProvider),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          child: Text(
            initial,

            style: TextStyle(
              fontSize: radius * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
