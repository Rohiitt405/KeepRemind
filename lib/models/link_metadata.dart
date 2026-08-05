import 'social_platform.dart';

class MetadataResult {
  final String title;
  final String caption;
  final String thumbnailUrl;
  final SocialPlatform platform;

  MetadataResult({
    required this.title,
    required this.caption,
    required this.thumbnailUrl,
    required this.platform,
  });
}
