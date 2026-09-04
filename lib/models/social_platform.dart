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

  Widget getIcon({double size = 16, Color? color}) {
    switch (this) {
      case SocialPlatform.youtube:
        return FaIcon(FontAwesomeIcons.youtube, size: size, color: color);
      case SocialPlatform.instagram:
        return FaIcon(FontAwesomeIcons.instagram, size: size, color: color);
      case SocialPlatform.facebook:
        return FaIcon(FontAwesomeIcons.facebook, size: size, color: color);
      case SocialPlatform.reddit:
        return FaIcon(FontAwesomeIcons.reddit, size: size, color: color);
      case SocialPlatform.linkedin:
        return FaIcon(FontAwesomeIcons.linkedin, size: size, color: color);
      case SocialPlatform.pinterest:
        return FaIcon(FontAwesomeIcons.pinterest, size: size, color: color);
      case SocialPlatform.x:
        return FaIcon(FontAwesomeIcons.xTwitter, size: size, color: color);
      case SocialPlatform.threads:
        return FaIcon(FontAwesomeIcons.threads, size: size, color: color);
      case SocialPlatform.snapchat:
        return FaIcon(FontAwesomeIcons.snapchat, size: size, color: color);
      case SocialPlatform.unknown:
        return Icon(Icons.link_rounded, size: size, color: color);
    }
  }

  Widget get iconWidget => getIcon(size: 30, color: Colors.black);
}
