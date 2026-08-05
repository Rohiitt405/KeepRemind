import 'social_platform.dart';

class SavedLink {
  final String? aiMemory;
  final List<String>? aiTags;
  final bool isGenerating;

  final String id;
  final String url;
  final String title;
  final String caption;
  final String thumbnailUrl;
  final SocialPlatform platform;
  final DateTime savedAt;
  final bool isReviewed;

  const SavedLink({
    this.aiMemory,
    this.aiTags,
    this.isGenerating = false,
    required this.id,
    required this.url,
    required this.title,
    required this.caption,
    required this.thumbnailUrl,
    required this.platform,
    required this.savedAt,
    required this.isReviewed,
  });

  Map<String, dynamic> toMap() {
    return {
      'aiMemory': aiMemory,
      'aiTags': aiTags,
      'aiGenerating': isGenerating,
      'url': url,
      'title': title,
      'caption': caption,
      'thumbnailUrl': thumbnailUrl,

      // Store enum as String in Firestore
      'platform': platform.value,

      'savedAt': savedAt.toIso8601String(),
      'isReviewed': isReviewed,
    };
  }

  factory SavedLink.fromMap(String id, Map<String, dynamic> map) {
    return SavedLink(
      aiMemory: map['aiMemory'] as String?,
      aiTags: map['aiTags'] != null ? List<String>.from(map['aiTags']) : null,
      isGenerating: map['aiGenerating'] == true,
      id: id,
      url: map['url'] ?? '',
      title: map['title'] ?? '',
      caption: map['caption'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',

      platform: SocialPlatformExtension.fromString(
        map['platform'] ?? 'unknown',
      ),

      savedAt: DateTime.parse(map['savedAt']),
      isReviewed: map['isReviewed'] ?? false,
    );
  }

  SavedLink copyWith({
    String? aiMemory,
    List<String>? aiTags,
    bool? isGenerating,
    String? id,
    String? url,
    String? title,
    String? caption,
    String? thumbnailUrl,
    SocialPlatform? platform,
    DateTime? savedAt,
    bool? isReviewed,
  }) {
    return SavedLink(
      aiMemory: aiMemory ?? this.aiMemory,
      aiTags: aiTags ?? this.aiTags,
      isGenerating: isGenerating ?? this.isGenerating,
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      platform: platform ?? this.platform,
      savedAt: savedAt ?? this.savedAt,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }
}
