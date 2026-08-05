import 'metadata_fetch_service.dart';
import '../../models/link_metadata.dart';
import 'platform_detector_service.dart';
import 'fallback_metadata_service.dart';

class MetadataService {
  final PlatformDetector _platformDetector = PlatformDetector();
  final GenericMetadataService _genericMetadataService =
      GenericMetadataService();
  final SocialMediaFallback _fallback = SocialMediaFallback();

  bool isValidUrl(String url) {
    final uri = Uri.tryParse(url);

    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<MetadataResult> fetchMetadata(String url) async {
    final platform = _platformDetector.detectPlatform(url);

    try {
      final metadata = await _genericMetadataService.fetchMetadata(
        url,
        platform,
      );

      return metadata;
    } catch (_) {
      return _fallback.generate(url: url, platform: platform);
    }
  }
}
