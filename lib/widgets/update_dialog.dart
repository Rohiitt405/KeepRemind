import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/update_info.dart';

class UpdateDialog {
  const UpdateDialog._();

  static Future<void> show(
    BuildContext context,
    UpdateInfo updateInfo,
  ) async {
    if(!context.mounted)  return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.system_update_alt_rounded,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text("Update Available"),
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Version: ${updateInfo.currentVersion}",
                ),
                const SizedBox(height: 8),
                Text(
                  "Latest Version: ${updateInfo.latestVersion}",
                ),
                const SizedBox(height: 16),

                const Text(
                  "What's new",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  updateInfo.releaseNotes.isEmpty
                    ? "Bug fixes and performance improvments"
                    : updateInfo.releaseNotes,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () {
              Navigator.of(context).pop();
            }, child: Text("Later"),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.download_rounded),
              label: const Text("Update"),
              onPressed: () async {
                final url = updateInfo.downloadUrl.isNotEmpty
                  ? updateInfo.downloadUrl
                  : updateInfo.releasePageUrl;
                
                final uri = Uri.parse(url);

                if(await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            )
          ],
        );
    });
  }
}