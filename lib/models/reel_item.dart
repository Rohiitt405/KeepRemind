class ReelItem {
  final String id;
  final String url;
  final String title;
  final String caption;
  final String thumbnailUrl;
  final List<String> takeaways;
  final String platform;
  final DateTime savedAt;
  final bool isReviewed;

  ReelItem({
    required this.id,
    required this.url,
    required this.title,
    required this.caption,
    required this.thumbnailUrl,
    required this.takeaways,
    required this.platform,
    required this.savedAt,
    required this.isReviewed,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title' : title,
      'caption' : caption,
      'thumbnailUrl' : thumbnailUrl,
      'takeaways' : takeaways,
      'platform' : platform,
      'savedAt' : savedAt.toIso8601String(),
      'isReviewed' : isReviewed,
    }; 
  }

  factory ReelItem.fromMap(String id, Map<String, dynamic> map) {
    return ReelItem(
      id: id,
      url: map['url'] ?? '',
      title: map['title'] ?? '',
      caption: map['caption'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      takeaways: List<String>.from(map['takeways'] ?? []),
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
    List<String>? takeaways,
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
      takeaways: takeaways ?? this.takeaways,
      platform: platform ?? this.platform,
      savedAt: savedAt ?? this.savedAt,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }
}