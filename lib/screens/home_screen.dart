import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reel_provider.dart';
import '../widgets/reel_card.dart';
import '../models/reel_item.dart';
import 'detail_screen.dart';
import 'add_url_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 tabs: All, Unreviewed, Reviewed
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReelProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ReelRemind',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All (${provider.reels.length})'),
            Tab(text: 'Unreviewed (${provider.unreviewedReels.length})'),
            Tab(text: 'Reviewed (${provider.reviewedReels.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReelList(context, provider.reels),
          _buildReelList(context, provider.unreviewedReels),
          _buildReelList(context, provider.reviewedReels),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddUrlScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Reel'),
      ),
    );
  }

  // Builds the scrollable list for a given set of reels
  Widget _buildReelList(BuildContext context, List<ReelItem> reels) {
    if (reels.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reels.length,
      itemBuilder: (context, index) {
        final reel = reels[index];
        return ReelCard(
          reel: reel,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(reel: reel),
            ),
          ),
          onDelete: () => _confirmDelete(context, reel.id),
        );
      },
    );
  }

  // Empty state UI when no reels are saved
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No saved reels yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to save your first reel',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // Confirm before deleting
  Future<void> _confirmDelete(BuildContext context, String reelId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reel?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<ReelProvider>().deleteReel(reelId);
    }
  }
}