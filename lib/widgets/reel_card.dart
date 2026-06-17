
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/reel_item.dart';

class ReelCard extends StatelessWidget {
  final ReelItem reel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReelCard({
    super.key,
    required this.reel,
    required this.onTap,
    required this.onDelete,
    });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            _buildThumbnail(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildPlatformBadge(),
                        const Spacer(),
                        
                        if (reel.isReviewed)
                          const Icon(Icons.check_circle,
                          color: Colors.green, size: 20,),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      reel.title.isNotEmpty ? reel.title : 'No title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    if(reel.aiMemory != null && reel.aiMemory!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '💡 ${reel.aiMemory}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Saved ${_formatDate(reel.savedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    )
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if(reel.thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: reel.thumbnailUrl,
        width: 100,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) => _thumbnailPlaceholder(),
        errorWidget: (context, url, error) => _thumbnailPlaceholder(),
      );
    }
    return _thumbnailPlaceholder();
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      width: 100,
      height: 120,
      color: Colors.grey[200],
      child: const Icon(Icons.video_library, color: Colors.grey),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPlatformBadge() {
    final isInstgram = reel.platform == 'instagram';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isInstgram ? Colors.purple[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),

      child: Text(
        isInstgram ? 'Instagram' : 'Youtube',
        style: TextStyle(
          fontSize: 11,
          color:  isInstgram ? Colors.purple[900] : Colors.red[900],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}