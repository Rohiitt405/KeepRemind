import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/reel_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddUrlScreen extends StatefulWidget {
  final String? initialUrl;

  const AddUrlScreen({super.key, this.initialUrl});

  @override
  State<AddUrlScreen> createState() => _AddUrlScreenState();
}

class _AddUrlScreenState extends State<AddUrlScreen> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _pressed = false;

  // Neo-Brutalist Color Tokens
  static const Color primaryColor = Colors.black;
  static const Color backgroundColor = Color(0xFFF9F9F9);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color tertiaryFixed = Color(0xFF72FF70);
  static const Color secondaryFixed = Color(0xFFEAEA00);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color onSurfaceVariant = Color(0xFF4C4546);

  List<BoxShadow> get neoShadowSm => const [
        BoxShadow(
          color: Colors.black,
          offset: Offset(4, 4),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _urlController.text = widget.initialUrl!;
        }
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _urlController.text = data!.text!;
      });
    }
  }

  Future<void> _saveReel() async {
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    final provider = context.read<ReelProvider>();

    await provider.saveReelFromUrl(url);

    if (mounted) {
      setState(() => _pressed = false);
    }

    if (context.mounted && provider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reel saved successfully! 🎉',
            style: GoogleFonts.jetBrainsMono(
              textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReelProvider>();
    
    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          shape: const Border(
            bottom: BorderSide(color: primaryColor, width: 6),
          ),
          title: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                  child: const Icon(Icons.keyboard_return, color: primaryColor),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'ADD_CONTENT',
                style: displayFont.copyWith(
                  fontSize: 28,
                  color: primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: DotGridOverlay(),
              ),
            ),
            
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: primaryColor, width: 4),
                          boxShadow: neoShadowSm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: const BoxDecoration(
                                color: tertiaryFixed,
                                border: Border(bottom: BorderSide(color: primaryColor, width: 2)),
                              ),
                              child: Text(
                                'INPUT_SOURCE_COLLECTOR',
                                style: monoFont.copyWith(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'PASTE YOUTUBE OR INSTGRAM LINK',
                                    style: spaceFont.copyWith(fontSize: 24, color: primaryColor, letterSpacing: 0.5, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Brutalist Input Box Style with embedded Action Label
                                  TextFormField(
                                    controller: _urlController,
                                    keyboardType: TextInputType.url,
                                    autocorrect: false,
                                    style: monoFont.copyWith(fontSize: 14, color: primaryColor),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'ERR: PIPELINE_EMPTY';
                                      }
                                      if (!value.startsWith('http')) {
                                        return 'ERR: INVALID_URL_HEADER';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: surfaceContainerLow,
                                      hintText: 'Paste Instagram/YouTube link...',
                                      hintStyle: monoFont.copyWith(color: onSurfaceVariant.withValues(alpha: 0.5)),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.assignment, color: primaryColor),
                                        onPressed: _pasteFromClipboard,
                                      ),
                                      errorStyle: monoFont.copyWith(color: errorColor, fontWeight: FontWeight.bold),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: primaryColor, width: 3),
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: primaryColor, width: 4),
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      errorBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: errorColor, width: 3),
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      focusedErrorBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: errorColor, width: 4),
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Error Terminal Block ---
                      if (provider.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.black,
                          child: Text(
                            '>> ERROR_LOG: ${provider.errorMessage}',
                            style: monoFont.copyWith(color: const Color(0xFFFFDAD6), fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      GestureDetector(
                        onTapDown: (_) => setState(() => _pressed = true),
                        onTapUp: (_) => setState(() => _pressed = false),
                        onTapCancel: () => setState(() => _pressed = false),

                        child: InkWell(
                          onTap: provider.isLoading ? null : _saveReel,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            transform: Matrix4.translationValues(
                              _pressed ? 4 : 0,
                              _pressed ? 4 : 0,
                              0,
                            ),

                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              color: secondaryFixed,
                              border: Border.all(
                                color: primaryColor,
                                width: 2,
                              ),

                              boxShadow: _pressed
                                  ? []
                                  : [
                                      const BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(4, 4),
                                        blurRadius: 0,
                                      ),
                                    ],
                            ),

                            child: provider.isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'FETCH DATA',
                                        style: spaceFont.copyWith(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 26,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.flash_on,
                                        color: primaryColor,
                                        size: 28,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      Text(
                        '// OPERATION_ON_FETCH_DATA',
                        style: monoFont.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildPipelineStep('META_EXTRACTION', 'Title and thumbnail are extracted from the Url', tertiaryFixed, monoFont),
                      _buildPipelineStep('AI_MEMORY', 'AI generate 3-5 tags, and memory', secondaryFixed, monoFont),
                      _buildPipelineStep('PRIVATE_STORAGE', 'Everything is saved to your phone storage', errorColor, monoFont),
                      _buildPipelineStep('SCHEDULED_REMINDER', 'You\'ll get a Weekly/Daily reminder to review it', Colors.grey, monoFont),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, String value, Color color, TextStyle monoFont, {bool textInvert = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: primaryColor, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: monoFont.copyWith(fontSize: 9, color: onSurfaceVariant, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: color,
              child: Text(
                value,
                style: monoFont.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: textInvert ? Colors.white : Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStep(String header, String body, Color stepColor, TextStyle monoFont) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: primaryColor, width: 10), bottom: BorderSide(color: primaryColor, width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 15,
            width: 15,
            color: stepColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(header, style: monoFont.copyWith(fontSize: 12, fontWeight: FontWeight.w900, color: primaryColor)),
                const SizedBox(height: 5),
                Text(body, style: monoFont.copyWith(fontSize: 13, color: onSurfaceVariant, height: 1.2)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- Custom Grid Pattern Canvas Painter Layer ---

class DotGridOverlay extends StatelessWidget {
  const DotGridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter());
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const double spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}