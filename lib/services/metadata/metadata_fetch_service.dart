import 'package:metadata_fetch/metadata_fetch.dart';

import '../../models/social_platform.dart';
import '../../models/link_metadata.dart';

class GenericMetadataService {
  Future<MetadataResult> fetchMetadata(
    String url,
    SocialPlatform platform,
  ) async {
    final data = await MetadataFetch.extract(url);

    return MetadataResult(
      title: _clean(data?.title),
      caption: _clean(data?.description),
      thumbnailUrl: _clean(data?.image),
      platform: platform,
    );
  }

  String _clean(String? value) {
    if (value == null) {
      return '';
    }

    return value.trim();
  }
}
