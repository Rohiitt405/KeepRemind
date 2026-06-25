import 'package:flutter/material.dart';
import 'package:project/screens/settings_screen.dart';
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
          'KeepRemind',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          )
        ],
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

  // Wrap ListView with RefreshIndicator for pull to refresh
  return RefreshIndicator(
    onRefresh: () async {
      // Reels stream auto-updates, but this gives visual feedback
      await Future.delayed(const Duration(milliseconds: 800));
    },
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reels.length,
      itemBuilder: (context, index) {
        final reel = reels[index];

        // Wrap each card with Dismissible for swipe to delete
        return Dismissible(
          key: Key(reel.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 28),
          ),
          // Confirm before dismissing
          confirmDismiss: (_) async {
            return await showDialog<bool>(
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
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) {
            context.read<ReelProvider>().deleteReel(reel.id);
          },
          child: ReelCard(
            reel: reel,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(reel: reel)),
            ),
            onDelete: () => _confirmDelete(context, reel.id),
          ),
        );
      },
    ),
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