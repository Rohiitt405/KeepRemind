import 'dart:async';
import 'package:flutter/material.dart';

import '../models/social_platform.dart';
import '../models/saved_link_model.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../services/metadata/metadata_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class SavedLinkProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final MetadataService _metadataService = MetadataService();
  final NotificationService _notificationService = NotificationService();
  final AiService _aiService = AiService();

  StreamSubscription<List<SavedLink>>? _savedLinksSubscription;
  Completer<void>? _initialDataCompleter;

  List<SavedLink> _savedLinks = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedInitialData = false;

  List<SavedLink> get savedLinks => _savedLinks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SavedLink> get unreviewedSavedLinks =>
      _savedLinks.where((link) => !link.isReviewed).toList();

  List<SavedLink> get reviewedSavedLinks =>
      _savedLinks.where((link) => link.isReviewed).toList();

  void listenToSavedLinks() {
    _savedLinksSubscription?.cancel();

    _savedLinksSubscription = _firestoreService.getSavedLinks().listen(
      (savedLinks) {
        _savedLinks = savedLinks;

        if (!_hasLoadedInitialData) {
          _hasLoadedInitialData = true;
          _initialDataCompleter?.complete();
          _initialDataCompleter = null;
        }

        notifyListeners();
      },
      onError: (error) {
        debugPrint('SavedLink stream error: $error');

        if (!_hasLoadedInitialData) {
          _hasLoadedInitialData = true;
          _initialDataCompleter?.complete();
          _initialDataCompleter = null;
        }
      },
    );
  }

  Future<void> ensureInitialDataLoaded({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    if (_hasLoadedInitialData) return;

    final completer = Completer<void>();
    _initialDataCompleter = completer;

    try {
      await completer.future.timeout(timeout);
    } on TimeoutException {
      debugPrint('Timed out waiting for initial saved links.');
    } finally {
      if (_initialDataCompleter == completer) {
        _initialDataCompleter = null;
      }
    }
  }

  Future<void> saveSavedLinkFromUrl(String url) async {
    if (!_metadataService.isValidUrl(url)) {
      _errorMessage = 'Please enter a valid URL.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final metadata = await _metadataService.fetchMetadata(url);

      final savedLink = SavedLink(
        id: '',
        url: url,
        title: metadata.title,
        caption: metadata.caption,
        thumbnailUrl: metadata.thumbnailUrl,
        platform: metadata.platform,
        aiMemory: null,
        aiTags: null,
        isGenerating: true,
        savedAt: DateTime.now(),
        isReviewed: false,
      );

      final savedLinkId = await _firestoreService.saveSavedLink(savedLink);

      final newSavedLink = savedLink.copyWith(id: savedLinkId);

      if (!_savedLinks.any((item) => item.id == savedLinkId)) {
        _savedLinks.insert(0, newSavedLink);
        notifyListeners();
      }

      final settingsService = SettingsService();
      final settings = await settingsService.loadReminderSettings();

      await _notificationService.scheduleWeeklyReminder(
        weekday: settings['weekday']!,
        hour: settings['hour']!,
        minute: settings['minute']!,
      );

      unawaited(
        _generateAiForSavedLink(
          reelId: savedLinkId,
          url: url,
          platform: metadata.platform.value,
          title: metadata.title,
          caption: metadata.caption,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('SAVE LINK ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _generateAiForSavedLink({
    required String reelId,
    required String url,
    required String platform,
    required String title,
    required String caption,
  }) async {
    const retryDelays = [
      Duration(seconds: 5),
      Duration(seconds: 15),
      Duration(seconds: 30),
      Duration(minutes: 1),
      Duration(minutes: 2),
    ];

    final maxAttempts = retryDelays.length + 1;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final aiMemory = await _aiService.generateMemory(
          url: url,
          platform: platform,
          title: title,
          caption: caption,
        );

        if (aiMemory != null && aiMemory.memory.trim().isNotEmpty) {
          await _firestoreService.updateSavedLink(reelId, {
            'aiMemory': aiMemory.memory,
            'aiTags': aiMemory.tags,
            'aiGenerating': false,
          });
          return;
        }
      } catch (e, stackTrace) {
        debugPrint(
          'AI generation error for $reelId (attempt ${attempt + 1}): $e',
        );
        debugPrintStack(stackTrace: stackTrace);
      }

      if (attempt < retryDelays.length) {
        await Future.delayed(retryDelays[attempt]);
      }
    }

    await _firestoreService.updateSavedLink(reelId, {'aiGenerating': false});
  }

  Future<void> toggleReviewed(SavedLink savedLink) async {
    try {
      await _firestoreService.setReviewed(savedLink.id, !savedLink.isReviewed);
    } catch (_) {
      _errorMessage = 'Could not update saved link.';
      notifyListeners();
    }
  }

  Future<void> deleteSavedLink(String savedLinkId) async {
    try {
      await _firestoreService.deleteSavedLink(savedLinkId);
    } catch (_) {
      _errorMessage = 'Could not delete saved link.';
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
