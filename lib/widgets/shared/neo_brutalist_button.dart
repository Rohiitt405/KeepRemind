import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';

class NeoBrutalistButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color disabledColor;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry padding;
  final bool enabled;

  const NeoBrutalistButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = AppThemeConstants.secondaryFixed,
    this.borderColor = AppThemeConstants.primaryColor,
    this.disabledColor = const Color(0xFFDADADA),
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.borderWidth = 4.0,
    this.boxShadow,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    this.enabled = true,
  });

  @override
  State<NeoBrutalistButton> createState() => _NeoBrutalistButtonState();
}

class _NeoBrutalistButtonState extends State<NeoBrutalistButton> {
  bool _isPressed = false;

  void _handleTapDown(_) {
    if (!widget.enabled || widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(_) {
    if (!widget.enabled || widget.onPressed == null) {
      setState(() => _isPressed = false);
      return;
    }
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: _isPressed
            ? Matrix4.translationValues(4, 4, 0)
            : Matrix4.translationValues(0, 0, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.enabled ? widget.backgroundColor : widget.disabledColor,
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.rectangle
              ? widget.borderRadius ?? BorderRadius.zero
              : null,
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          boxShadow: widget.boxShadow ?? AppThemeConstants.neoShadow,
        ),
        child: widget.child,
      ),
    );
  }
}
