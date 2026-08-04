import '../../models/social_platform.dart';
import '../../models/link_metadata.dart';

class SocialMediaFallback {
  MetadataResult generate({
    required String url,
    required SocialPlatform platform,
  }) {
    switch (platform) {
      case SocialPlatform.youtube:
        return MetadataResult(
          title: 'YouTube Video',
          caption: 'Saved YouTube video',
          thumbnailUrl: '',
          platform: platform,
        );

      case SocialPlatform.instagram:
        return MetadataResult(
          title: 'Instagram Post',
          caption: 'Saved Instagram post',
          thumbnailUrl: '',
          platform: platform,
        );

      case SocialPlatform.facebook:
        return MetadataResult(
          title: 'Facebook Post',
          caption: 'Saved Facebook post',
          thumbnailUrl: '',
          platform: platform,
        );

      case SocialPlatform.threads:
        return MetadataResult(
          title: 'Threads Post',
          caption: 'Saved Threads post',
          thumbnailUrl: '',
          platform: platform,
        );

      case SocialPlatform.reddit:
        return MetadataResult(
          title: 'Reddit Post',
          caption: 'Saved Reddit post',
          thumbnailUrl: '',
          platform: platform,
        );

      case SocialPlatform.linkedin:
        return MetadataResult(
          title: 'LinkedIn Post',
          caption: 'Saved LinkedIn post',
          thumbnailUrl: '',
          platform: platform,
        );

      case SocialPlatform.pinterest:
        return MetadataResult(
          title: 'Pinterest Pin',
          caption: 'Saved Pinterest pin',
          thumbnailUrl: '',
          platform: platform,
        );

      case SocialPlatform.x:
        return MetadataResult(
          title: 'X Post',
          caption: 'Saved X post',
          thumbnailUrl: '',
          platform: platform,
        );

      case SocialPlatform.snapchat:
        return MetadataResult(
          title: 'Snapchat Story',
          caption: 'Saved Snapchat content',
          thumbnailUrl: '',
          platform: platform,
        );

      case SocialPlatform.unknown:
        return MetadataResult(
          title: 'Saved Link',
          caption: url,
          thumbnailUrl: '',
          platform: platform,
        );
    }
  }
}