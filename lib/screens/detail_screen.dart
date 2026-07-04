import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/reel_item.dart';
import '../providers/reel_provider.dart';

class DetailScreen extends StatelessWidget {
  final ReelItem reel;

  const DetailScreen({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReelProvider>();
    final currentReel = provider.reels.firstWhere(
      (item) => item.id == reel.id,
      orElse: () => reel,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, currentReel),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlatformBadge(currentReel),
                  const SizedBox(height: 10),
                  _buildTitle(currentReel),
                  const SizedBox(height: 20),
                  if (currentReel.caption.isNotEmpty) _buildCaptionSection(currentReel),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, currentReel),
                  const SizedBox(height: 40),

                  if (currentReel.isGenerating)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AI memory is being generated. It will appear here when ready.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (!currentReel.isGenerating && currentReel.aiMemory != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Why You Saved This',
                              style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(currentReel.aiMemory!),
                          ],
                        ),
                      ),
                    ),
                  
                  Wrap(
                    spacing: 8,
                    children: currentReel.aiTags
                        ?.map(
                          (tag) => Chip(
                            label: Text(tag),
                          ),
                        )
                        .toList() ?? [],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ReelItem currentReel) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: reel.thumbnailUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: reel.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.video_library,
                      size: 60, color: Colors.grey),
                ),
              )
            : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.video_library,
                    size: 60, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildPlatformBadge(ReelItem currentReel) {
    final isInstagram = currentReel.platform == 'instagram';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isInstagram ? Colors.purple[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isInstagram ? '📸 Instagram' : '▶️ YouTube',
        style: TextStyle(
          color: isInstagram ? Colors.purple : Colors.red,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTitle(ReelItem currentReel) {
    return Text(
      currentReel.title.isNotEmpty ? currentReel.title : 'No title available',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCaptionSection(ReelItem currentReel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 Caption',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          currentReel.caption,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ReelItem currentReel) {
    final provider = context.read<ReelProvider>();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openUrl(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Original'),
          ),
        ),
        const SizedBox(height: 12),
        if (!currentReel.isReviewed)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await provider.markAsReviewed(currentReel.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as reviewed ✅')),
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark as Reviewed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                'Reviewed',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.parse(reel.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
      }
    }
  }
}