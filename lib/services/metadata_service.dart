import 'package:metadata_fetch/metadata_fetch.dart';

class MetadataResult {
  final String title;
  final String caption;
  final String thumbnailUrl;
  final String platform;

  MetadataResult({
    required this.title,
    required this.caption,
    required this.thumbnailUrl,
    required this.platform,
  });
}

class MetadataService {
  String _detectPlatform(String url) {

    if(url.contains('instagram.com') || url.contains('instagra.am')) {
      return 'instagram';
    } else if(url.contains('youtube.com') || url.contains('youtu.be')) {
      return 'youtube';
    }
    return 'other';
  }

  bool isValidUrl(String url) {
    final platform = _detectPlatform(url);
    return platform == 'instagram' || platform == 'youtube';
  }

  Future<MetadataResult> fetchMetadata(String url) async {
    try {
      final data = await MetadataFetch.extract(url);

      final title = data?.title ?? '';
      final caption = data?.description ?? '';
      final thumbnailUrl = data?.image ?? '';
      final platform = _detectPlatform(url);

      return MetadataResult(
        title: title, 
        caption: caption, 
        thumbnailUrl: thumbnailUrl, 
        platform: platform
      );

    } catch (e) {
      return MetadataResult(
        title: '', 
        caption: '', 
        thumbnailUrl: '', 
        platform: _detectPlatform(url),
      );
    }
  }
}