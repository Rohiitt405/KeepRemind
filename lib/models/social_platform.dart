import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum SocialPlatform {
  youtube,
  instagram,
  facebook,
  threads,
  reddit,
  linkedin,
  pinterest,
  x,
  snapchat,
  unknown,
}

/// Extension centralizing platform-related metadata used across the app.
///
/// Keeps label, color and icon in one place so UI code can remain thin and
/// avoid duplication.
extension SocialPlatformExtension on SocialPlatform {
  String get value {
    switch (this) {
      case SocialPlatform.youtube:
        return 'youtube';
      case SocialPlatform.instagram:
        return 'instagram';
      case SocialPlatform.facebook:
        return 'facebook';
      case SocialPlatform.threads:
        return 'threads';
      case SocialPlatform.reddit:
        return 'reddit';
      case SocialPlatform.linkedin:
        return 'linkedin';
      case SocialPlatform.pinterest:
        return 'pinterest';
      case SocialPlatform.x:
        return 'x';
      case SocialPlatform.snapchat:
        return 'snapchat';
      case SocialPlatform.unknown:
        return 'unknown';
    }
  }

  static SocialPlatform fromString(String value) {
    switch (value.toLowerCase()) {
      case 'youtube':
        return SocialPlatform.youtube;
      case 'instagram':
        return SocialPlatform.instagram;
      case 'facebook':
        return SocialPlatform.facebook;
      case 'threads':
        return SocialPlatform.threads;
      case 'reddit':
        return SocialPlatform.reddit;
      case 'linkedin':
        return SocialPlatform.linkedin;
      case 'pinterest':
        return SocialPlatform.pinterest;
      case 'x':
        return SocialPlatform.x;
      case 'snapchat':
        return SocialPlatform.snapchat;
      default:
        return SocialPlatform.unknown;
    }
  }

  /// Human friendly uppercase label used in badges.
  String get label {
    switch (this) {
      case SocialPlatform.youtube:
        return 'YOUTUBE';
      case SocialPlatform.instagram:
        return 'INSTAGRAM';
      case SocialPlatform.facebook:
        return 'FACEBOOK';
      case SocialPlatform.threads:
        return 'THREADS';
      case SocialPlatform.reddit:
        return 'REDDIT';
      case SocialPlatform.linkedin:
        return 'LINKEDIN';
      case SocialPlatform.pinterest:
        return 'PINTEREST';
      case SocialPlatform.x:
        return 'X';
      case SocialPlatform.snapchat:
        return 'SNAPCHAT';
      case SocialPlatform.unknown:
        return 'LINK';
    }
  }

  /// Primary brand color used for platform badges and accents.
  Color get color {
    switch (this) {
      case SocialPlatform.youtube:
        return const Color(0xFFFF0000);
      case SocialPlatform.instagram:
        return const Color(0xFFE4405F);
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.reddit:
        return const Color(0xFFFF4500);
      case SocialPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SocialPlatform.pinterest:
        return const Color(0xFFE60023);
      case SocialPlatform.x:
        return const Color(0xFF929090);
      case SocialPlatform.snapchat:
        return const Color(0xFFFFFC00);
      case SocialPlatform.threads:
        return const Color(0xFF101010);
      case SocialPlatform.unknown:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Icon widget to display for the platform. Returns a properly configured
  /// [Widget] so callers don't need to decide between [FaIcon] and [Icon].
  Widget get iconWidget {
    switch (this) {
      case SocialPlatform.youtube:
        return const FaIcon(FontAwesomeIcons.youtube, color: Colors.white, size: 30);
      case SocialPlatform.instagram:
        return const FaIcon(FontAwesomeIcons.instagram, color: Colors.white, size: 30);
      case SocialPlatform.facebook:
        return const FaIcon(FontAwesomeIcons.facebook, color: Colors.white, size: 30);
      case SocialPlatform.reddit:
        return const FaIcon(FontAwesomeIcons.reddit, color: Colors.white, size: 30);
      case SocialPlatform.linkedin:
        return const FaIcon(FontAwesomeIcons.linkedin, color: Colors.white, size: 30);
      case SocialPlatform.pinterest:
        return const FaIcon(FontAwesomeIcons.pinterest, color: Colors.white, size: 30);
      case SocialPlatform.x:
        return const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.white, size: 30);
      case SocialPlatform.threads:
        return const FaIcon(FontAwesomeIcons.threads, color: Colors.white, size: 30);
      case SocialPlatform.snapchat:
        return const FaIcon(FontAwesomeIcons.snapchat, color: Colors.white, size: 30);
      case SocialPlatform.unknown:
        return const Icon(Icons.link_rounded, color: Colors.white, size: 30);
    }
  }
}
