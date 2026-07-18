import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();

  String _reminderType = 'weekly';
  int _selectedWeekday = DateTime.monday;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isLoading = true;
  bool _isSaving = false;

  final Map<int, String> _weekdays = {
    DateTime.monday: 'MON',
    DateTime.tuesday: 'TUE',
    DateTime.wednesday: 'WED',
    DateTime.thursday: 'THU',
    DateTime.friday: 'FRI',
    DateTime.saturday: 'SAT',
    DateTime.sunday: 'SUN',
  };

  // Neo-Brutalist Global Design Tokens
  static const Color primaryColor = Colors.black;
  static const Color backgroundColor = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Colors.white;
  static const Color tertiaryFixed = Color(0xFF72FF70);
  static const Color secondaryFixed = Color(0xFFEAEA00);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color onSurfaceVariant = Color(0xFF4C4546);

  List<BoxShadow> get neoShadow => const [
        BoxShadow(
          color: Colors.black,
          offset: Offset(6, 6),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: backgroundColor,
    ));
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadReminderSettings();
    setState(() {
      _reminderType = settings['type'] as String;
      _selectedWeekday = settings['weekday'] as int;
      _selectedTime = TimeOfDay(
        hour: settings['hour'] as int,
        minute: settings['minute'] as int,
      );
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      await _settingsService.saveReminderSettings(
        type: _reminderType,
        weekday: _selectedWeekday,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );

      if (_reminderType == 'daily') {
        await _notificationService.scheduleDailyReminder(
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
        );
      } else {
        await _notificationService.scheduleWeeklyReminder(
          weekday: _selectedWeekday,
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'SUCCESS: REMINDER_MATRIX_UPDATED',
              style: GoogleFonts.jetBrainsMono(
                textStyle: const TextStyle(color: tertiaryFixed, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'CRITICAL_ERR: HANDSHAKE_FAILED',
              style: GoogleFonts.jetBrainsMono(
                textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: backgroundColor,
              onSurface: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.anton();
    final monoFont = GoogleFonts.jetBrainsMono();
    final spaceFont = GoogleFonts.spaceGrotesk();

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      child: Scaffold(
        // --- Top Bar Component ---
        appBar: AppBar(
          backgroundColor: backgroundColor,
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
                  child: const Icon(Icons.arrow_back, color: primaryColor),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'REMINDER',
                style: displayFont.copyWith(
                  fontSize: 28,
                  color: primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : Stack(
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: DotGridOverlay(),
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- Terminal Protocol Header Section ---
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: surfaceContainerLowest,
                              border: Border.all(color: primaryColor, width: 4),
                              boxShadow: neoShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: '[REMINDER_SETTING]',
                                    style: monoFont.copyWith(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      backgroundColor: secondaryFixed,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'NEVER MISS WHAT MATTERS. SET A REMINDER TO STAY ORGANIZED, MEET YOUR DEADLINES, AND KEEP UP WITH THE THINGS THAT ARE IMPORTANT TO YOU.',
                                  style: monoFont.copyWith(
                                    fontSize: 11,
                                    color: onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          
                          Row(
                            children: [
                              const Icon(Icons.schedule, color: primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'REMINDER_TARGET',
                                style: spaceFont.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onTap: _pickTime,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: primaryColor, width: 4),
                                    boxShadow: neoShadow,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      border: Border.all(color: primaryColor, width: 8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _formatTimeOfDay(_selectedTime),
                                          style: displayFont.copyWith(
                                            color: tertiaryFixed,
                                            fontSize: 70,
                                            letterSpacing: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: tertiaryFixed,
                                    border: Border.all(color: primaryColor, width: 4),
                                  ),
                                  child: Text(
                                    '24H_MODE_ACTIVE',
                                    style: monoFont.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 25),

                          Row(
                            children: [
                              const Icon(Icons.update, color: primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'SYNC_FREQUENCY',
                                style: spaceFont.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildTerminalToggleOption('DAILY', _reminderType == 'daily', () {
                                setState(() => _reminderType = 'daily');
                              }, tertiaryFixed, monoFont),
                              const SizedBox(width: 16),
                              _buildTerminalToggleOption('WEEKLY', _reminderType == 'weekly', () {
                                setState(() => _reminderType = 'weekly');
                              }, tertiaryFixed, monoFont),
                            ],
                          ),
                          const SizedBox(height: 25),

                          if (_reminderType == 'weekly') ...[
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: primaryColor, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'ON_THIS_DAY',
                                  style: spaceFont.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _weekdays.entries.map((entry) {
                                final isSelected = _selectedWeekday == entry.key;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedWeekday = entry.key),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? secondaryFixed : surfaceContainerLowest,
                                      border: Border.all(color: primaryColor, width: 3),
                                      boxShadow: isSelected ? null : neoShadowSm,
                                    ),
                                    transform: isSelected
                                        ? Matrix4.translationValues(2, 2, 0)
                                        : Matrix4.translationValues(0, 0, 0),
                                    child: Text(
                                      entry.value,
                                      style: spaceFont.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),
                          ],

                          NeoBrutalistSynchronizeButton(
                            onPressed: _isSaving ? () {} : _saveSettings,
                            isLoading: _isSaving,
                            displayFont: displayFont,
                            backgroundColor: secondaryFixed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTerminalToggleOption(
    String label,
    bool isActive,
    VoidCallback onTap,
    Color activeColor,
    TextStyle monoFont,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? activeColor : surfaceContainerLowest,
            border: Border.all(color: primaryColor, width: 4),
            boxShadow: isActive
                ? const [BoxShadow(color: primaryColor, offset: Offset(2, 2))]
                : neoShadowSm,
          ),
          transform: isActive
              ? Matrix4.translationValues(2, 2, 0)
              : Matrix4.translationValues(0, 0, 0),
          child: Text(
            '[ $label ]',
            style: monoFont.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? primaryColor : onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class NeoBrutalistSynchronizeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final TextStyle displayFont;
  final Color backgroundColor;

  const NeoBrutalistSynchronizeButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.displayFont,
    required this.backgroundColor,
  });

  @override
  State<NeoBrutalistSynchronizeButton> createState() => _NeoBrutalistSynchronizeButtonState();
}

class _NeoBrutalistSynchronizeButtonState extends State<NeoBrutalistSynchronizeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: _isPressed
            ? Matrix4.translationValues(4, 4, 0)
            : Matrix4.translationValues(0, 0, 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: _isPressed
              ? const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                  )
                ]
              : const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(6, 6),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SYNCHRONIZE',
                      style: widget.displayFont.copyWith(
                        fontSize: 28,
                        letterSpacing: 2,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.bolt, color: Colors.black, size: 30),
                  ],
                ),
        ),
      ),
    );
  }
}

// --- Canvas Alignment Elements ---

class DotGridOverlay extends StatelessWidget {
  const DotGridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotGridPainter(),
    );
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