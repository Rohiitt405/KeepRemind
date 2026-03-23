import 'package:flutter/material.dart';
import '../models/reel_item.dart';
import '../services/firestore_service.dart';
import '../services/metadata_service.dart';
import '../services/ai_service.dart';

class ReelProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final MetadataService _metadataService = MetadataService();
  final AiService _aiService = AiService();

  List<ReelItem> _reels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReelItem> get reels => _reels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ReelItem> get unreviewedReels => _reels.where((r) => !r.isReviewed).toList();
  List<ReelItem> get reviewedReels => _reels.where((r) => r.isReviewed).toList();

  void listenToReels() {
    _firestoreService.getReels().listen((reels) {
      _reels = reels;
      notifyListeners();
    });
  }

  Future<void> saveReelFromUrl(String url) async {
    if(!_metadataService.isValidUrl(url)) {
      _errorMessage = 'Only Instagram and Youtube links are supported.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final metadata = await _metadataService.fetchMetadata(url);
      final takeaways = await _aiService.generateTakeaways(
        metadata.title, 
        metadata.caption
      );

      final reel = ReelItem(
        id: '',
        url: url,
        title: metadata.title,
        caption: metadata.caption,
        thumbnailUrl: metadata.thumbnailUrl,
        takeaways: takeaways,
        platform: metadata.platform,
        savedAt: DateTime.now(),
        isReviewed: false
      );

      await _firestoreService.saveReel(reel);

    } catch (e) {
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