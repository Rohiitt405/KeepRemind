import '../../models/social_platform.dart';

class PlatformDetector {
  SocialPlatform detectPlatform(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return SocialPlatform.unknown;
    }

    final host = uri.host.toLowerCase();

    if (host.contains('youtube.com') || host.contains('youtu.be')) {
      return SocialPlatform.youtube;
    }

    if (host.contains('instagram.com')) {
      return SocialPlatform.instagram;
    }

    if (host.contains('facebook.com') || host.contains('fb.watch')) {
      return SocialPlatform.facebook;
    }

    if (host.contains('threads.net')) {
      return SocialPlatform.threads;
    }

    if (host.contains('reddit.com')) {
      return SocialPlatform.reddit;
    }

    if (host.contains('linkedin.com')) {
      return SocialPlatform.linkedin;
    }

    if (host.contains('pinterest.com')) {
      return SocialPlatform.pinterest;
    }

    if (host == 'x.com' || host.contains('twitter.com')) {
      return SocialPlatform.x;
    }

    if (host.contains('snapchat.com')) {
      return SocialPlatform.snapchat;
    }

    return SocialPlatform.unknown;
  }
}
