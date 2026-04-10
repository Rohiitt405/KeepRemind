class ReelItem {
  final String id;
  final String url;
  final String title;
  final String caption;
  final String thumbnailUrl;
  final String platform;
  final DateTime savedAt;
  final bool isReviewed;

  ReelItem({
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
      'url': url,
      'title': title,
      'caption': caption,
      'thumbnailUrl': thumbnailUrl,
      'platform': platform,
      'savedAt': savedAt.toIso8601String(),
      'isReviewed': isReviewed,
    };
  }

  factory ReelItem.fromMap(String id, Map<String, dynamic> map) {
    return ReelItem(
      id: id,
      url: map['url'] ?? '',
      title: map['title'] ?? '',
      caption: map['caption'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      platform: map['platform'] ?? '',
      savedAt: DateTime.parse(map['savedAt']),
      isReviewed: map['isReviewed'] ?? false,
    );
  }

  ReelItem copyWith({
    String? id,
    String? url,
    String? title,
    String? caption,
    String? thumbnailUrl,
    String? platform,
    DateTime? savedAt,
    bool? isReviewed,
  }) {
    return ReelItem(
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