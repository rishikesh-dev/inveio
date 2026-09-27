import 'package:flutter/material.dart';

import 'gst_pill.dart';
import 'splash_colors.dart';

/// The central title, subtitle, and GST pill row on the splash screen.
class CenterContent extends StatelessWidget {
  /// The opacity driving the fade-in animation of the content.
  final double contentFade;

  const CenterContent({super.key, required this.contentFade});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: contentFade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: SplashColors.darkGreen,
                letterSpacing: -1,
              ),
              children: [
                TextSpan(text: 'Inve'),
                TextSpan(
                  text: 'io',
                  style: TextStyle(color: SplashColors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Smart GST · Happy Taxes',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: SplashColors.midGreen,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GstPill('5%'),
              SizedBox(width: 8),
              GstPill('12%', accent: true),
              SizedBox(width: 8),
              GstPill('18%', active: true),
              SizedBox(width: 8),
              GstPill('28%'),
            ],
          ),
        ],
      ),
    );
  }
}
