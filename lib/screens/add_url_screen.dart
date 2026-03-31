import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/reel_provider.dart';

class AddUrlScreen extends StatefulWidget {
  final String? initialUrl;

  const AddUrlScreen({super.key, this.initialUrl});

  @override
  State<AddUrlScreen> createState() => _AddUrlScreenState();
}

class _AddUrlScreenState extends State<AddUrlScreen> {
  // Controller lets us read and control the text field
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      // Small delay ensures the text field is mounted before we set text
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _urlController.text = widget.initialUrl!;
          print('✅ URL pre-filled: ${widget.initialUrl}');
        }
      });
    }
  }

  // Key lets us validate the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReelProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reel'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instruction text
              const Text(
                'Paste an Instagram Reel or YouTube Short URL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Text(
                'The app will extract the title, thumbnail and generate key takeaways automatically.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // URL input field
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://www.instagram.com/reel/...',
                  hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // Paste from clipboard button inside the field
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste),
                    tooltip: 'Paste from clipboard',
                    onPressed: _pasteFromClipboard,
                  ),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                // Validator runs when we call _formKey.currentState!.validate()
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a URL';
                  }
                  if (!value.startsWith('http')) {
                    return 'Please enter a valid URL starting with http';
                  }
                  return null; // null means valid
                },
              ),
              const SizedBox(height: 12),

              // Show error from provider if any
              if (provider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => context.read<ReelProvider>().clearError(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _saveReel,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processing...'),
                          ],
                        )
                      : const Text(
                          'Save Reel',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // What happens next info box
              _buildInfoBox(),
            ],
          ),
        ),
      ),
    );
  }

  // Paste URL from clipboard into the text field
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
    }
  }

  // Trigger the full save flow
  Future<void> _saveReel() async {
    // First validate the form field
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    final provider = context.read<ReelProvider>();

    await provider.saveReelFromUrl(url);

    // After save, check if there's no error — means success
    if (context.mounted && provider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reel saved successfully! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  // Info box explaining what the app does with the URL
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What happens when you save?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _infoRow('🔍', 'Title and thumbnail are extracted from the URL'),
          _infoRow('🤖', 'AI generates 3-5 key takeaways'),
          _infoRow('💾', 'Everything is saved to your personal library'),
          _infoRow('🔔', 'You\'ll get a weekly reminder to review it'),
        ],
      ),
    );
  }

  Widget _infoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: Colors.blue[800])),
          ),
        ],
      ),
    );
  }
}