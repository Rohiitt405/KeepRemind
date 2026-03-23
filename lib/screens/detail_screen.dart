import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/reel_item.dart';
import '../providers/reel_provider.dart';
import '../widgets/takeaway_chip.dart';

class DetailScreen extends StatelessWidget {
  final ReelItem reel;

  const DetailScreen({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible app bar with thumbnail
          _buildSliverAppBar(context),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlatformBadge(),
                  const SizedBox(height: 10),
                  _buildTitle(),
                  const SizedBox(height: 20),
                  _buildTakeawaysSection(),
                  const SizedBox(height: 20),
                  if (reel.caption.isNotEmpty) _buildCaptionSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // App bar that shows thumbnail and collapses on scroll
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: reel.thumbnailUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: reel.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[200],
                      child: const Icon(Icons.video_library, size: 60, color: Colors.grey)),
              )
            : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.video_library, size: 60, color: Colors.grey),
              ),
      ),
    );
  }

  // Platform badge (Instagram / YouTube)
  Widget _buildPlatformBadge() {
    final isInstagram = reel.platform == 'instagram';
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

  Widget _buildTitle() {
    return Text(
      reel.title.isNotEmpty ? reel.title : 'No title available',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // AI takeaways section
  Widget _buildTakeawaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🧠 Key Takeaways',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (reel.takeaways.isEmpty)
          Text('No takeaways available.',
              style: TextStyle(color: Colors.grey[500]))
        else
          ...reel.takeaways.asMap().entries.map(
                (entry) => TakeawayChip(
                  index: entry.key,
                  text: entry.value,
                ),
              ),
      ],
    );
  }

  // Original caption section
  Widget _buildCaptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 Original Caption',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          reel.caption,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Open URL + Mark as reviewed buttons
  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<ReelProvider>();

    return Column(
      children: [
        // Open original reel
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openUrl(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Original'),
          ),
        ),
        const SizedBox(height: 12),

        // Mark as reviewed (only show if not already reviewed)
        if (!reel.isReviewed)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await provider.markAsReviewed(reel.id);
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
              Text('Reviewed',
                  style: TextStyle(color: Colors.green[700],
                      fontWeight: FontWeight.w600)),
            ],
          ),
      ],
    );
  }

  // Launch the original URL in browser
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