import 'package:flutter/foundation.dart';
import '../models/update_info.dart';
import '../services/update_service.dart';

class UpdateProvider extends ChangeNotifier {
  final UpdateService _updateService = const UpdateService();

  bool _isChecking = false;
  bool _hasChecked = false;

  UpdateInfo? _updateInfo;
  bool get isChecking => _isChecking;
  bool get hasChecked => _hasChecked;
  UpdateInfo? get updateInfo => _updateInfo;
  bool get hasUpdate => _updateInfo?.hasUpdate ?? false;

  Future<void> checkForUpdate() async {
    if (_isChecking) return;

    _isChecking = true;
    notifyListeners();

    try {
      _updateInfo = await _updateService.checkForUpdate();
    } finally {
      _isChecking = false;
      _hasChecked = true;
      notifyListeners();
    }
  }

  void reset() {
    _updateInfo = null;
    _hasChecked = false;
    notifyListeners();
  }
}
