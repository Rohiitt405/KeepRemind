import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'settings_service.dart';
import '../constants/github_constants.dart';
import '../models/update_info.dart';
import '../utils/version_helper.dart';

class UpdateService {
  const UpdateService();

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse(GithubConstants.latestReleaseApi),
        headers: {'Accept': 'application/vnd.github+json'},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      final latestVersion = (json["tag_name"] as String).replaceFirst('v', '');

      final hasUpdate = VersionHelper.isNewerVersion(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
      );

      if(!hasUpdate) {
        return UpdateInfo.fromGithubJson(
          json: json,
          currentVersion: currentVersion,
          hasUpdate: false,
        );
      }
      
      final settingsService = SettingsService();
      final skippedVersion = await settingsService.getSkippedUpdateVersion();

      if(skippedVersion == latestVersion) {
        return UpdateInfo.fromGithubJson(
          json: json, 
          currentVersion: currentVersion, 
          hasUpdate: false,
        );
      }

      return UpdateInfo.fromGithubJson(
        json: json, 
        currentVersion: currentVersion, 
        hasUpdate: hasUpdate
      );
    } catch (e, stackTrace) {
      debugPrint("Update Error: $e");
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }
}
