import 'package:flutter/material.dart';
import 'package:project/models/ai_memory.dart';
import 'package:project/services/ai_service.dart';
import '../models/reel_item.dart';
import '../services/firestore_service.dart';
import '../services/metadata_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class ReelProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final MetadataService _metadataService = MetadataService();
  final NotificationService _notificationService = NotificationService();
  final AiService _aiService = AiService();

  List<ReelItem> _reels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReelItem> get reels => _reels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ReelItem> get unreviewedReels =>
      _reels.where((r) => !r.isReviewed).toList();
  List<ReelItem> get reviewedReels =>
      _reels.where((r) => r.isReviewed).toList();

  void listenToReels() {
    _firestoreService.getReels().listen((reels) {
      _reels = reels;
      notifyListeners();
    });
  }

  // Simplified save flow — no AI involved
  Future<void> saveReelFromUrl(String url) async {
    if (!_metadataService.isValidUrl(url)) {
      _errorMessage = 'Only Instagram and YouTube links are supported.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      // Step 1: Extract metadata from URL
      final metadata = await _metadataService.fetchMetadata(url);

      final aiMemory = await _aiService.generateMemory(
        title: metadata.title, 
        caption: metadata.caption
      );

      // Step 2: Build ReelItem
      final reel = ReelItem(
        id: '',
        url: url,
        title: metadata.title,
        caption: metadata.caption,
        thumbnailUrl: metadata.thumbnailUrl,
        platform: metadata.platform,

        aiMemory: aiMemory?.memory,
        aiTags: aiMemory?.tags,
        
        savedAt: DateTime.now(),
        isReviewed: false,
      );

      // Step 3: Save to Firestore and update local list immediately
      final savedReelId = await _firestoreService.saveReel(reel);
      final savedReel = reel.copyWith(id: savedReelId);
      if (!_reels.any((r) => r.id == savedReelId)) {
        _reels.insert(0, savedReel);
        notifyListeners();
      }

      // Step 4: Schedule weekly reminder
      final settingsService = SettingsService();
      final settings = await settingsService.loadReminderSettings();
      await _notificationService.scheduleWeeklyReminder(
        weekday: settings['weekday']!,
        hour: settings['hour']!,
        minute: settings['minute']!,
      );

    } catch (e, stackTrace) {
      debugPrint('SAVE REEL ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsReviewed(String reelId) async {
    try {
      await _firestoreService.markAsReviewed(reelId);
    } catch (e) {
      _errorMessage = 'Could not update reel.';
      notifyListeners();
    }
  }

  Future<void> deleteReel(String reelId) async {
    try {
      await _firestoreService.deleteReel(reelId);
    } catch (e) {
      _errorMessage = 'Could not delete reel.';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}