import 'package:flutter/material.dart';
import 'dart:ui';

class GlobalLoading {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;
  static GlobalKey<_LoadingOverlayState>? _overlayKey;
  static bool _isHiding = false;

  static void show(
    BuildContext context, {
    String? message,
    bool dismissible = false,
  }) {
    if (_isVisible || _isHiding) return;

    _isVisible = true;
    _overlayKey = GlobalKey<_LoadingOverlayState>();
    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlay(
        key: _overlayKey,
        message: message,
        dismissible: dismissible,
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          _isVisible = false;
          _isHiding = false;
          _overlayKey = null;
        },
      ),
    );

    try {
      Overlay.of(context).insert(_overlayEntry!);
    } catch (e) {
      // Reset state if overlay insertion fails
      _isVisible = false;
      _isHiding = false;
      _overlayEntry = null;
      _overlayKey = null;
    }
  }

  static Future<void> hide() async {
    if (!_isVisible || _isHiding || _overlayKey?.currentState == null) return;

    _isHiding = true;
    try {
      await _overlayKey!.currentState!.dismiss();
    } catch (e) {
      // Force hide if animation fails
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
      _isHiding = false;
      _overlayKey = null;
    }
  }

  static bool get isVisible => _isVisible;
}

class _LoadingOverlay extends StatefulWidget {
  final String? message;
  final bool dismissible;
  final VoidCallback? onDismiss;

  const _LoadingOverlay({
    Key? key,
    this.message,
    this.dismissible = false,
    this.onDismiss,
  }) : super(key: key);

  @override
  _LoadingOverlayState createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> dismiss() async {
    if (!mounted || _controller.isDismissed) return;

    try {
      await _controller.reverse();
    } catch (e) {
      // Handle animation errors
    } finally {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: widget.dismissible
            ? _buildDismissible(context)
            : _buildNonDismissible(context),
      ),
    );
  }

  Widget _buildDismissible(BuildContext context) {
    return GestureDetector(
      onTap: dismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildNonDismissible(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E).withOpacity(0.9)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 4,
                    color: theme.primaryColor.withOpacity(0.1),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF1B6EF3),
                      Color(0xFF6B8CFF),
                      Color(0xFFA07BF0),
                    ],
                    stops: [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                widget.message!,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Extension methods
extension GlobalLoadingExtension on BuildContext {
  void showLoading({String? message, bool dismissible = false}) {
    GlobalLoading.show(this, message: message, dismissible: dismissible);
  }

  Future<void> hideLoading() async {
    await GlobalLoading.hide();
  }
}
