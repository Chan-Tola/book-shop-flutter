import 'dart:ui';
import 'package:flutter/material.dart';

class GlobalLoading {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;
  static GlobalKey<_LoadingOverlayState>? _overlayKey;

  static void show(BuildContext context, {String? message}) {
    if (_isVisible) return;
    _isVisible = true;
    _overlayKey = GlobalKey<_LoadingOverlayState>();

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlay(key: _overlayKey, message: message),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static Future<void> hide() async {
    if (!_isVisible) return;
    try {
      await _overlayKey?.currentState?.dismiss();
    } catch (_) {
      // ignore animation errors
    } finally {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _overlayKey = null;
      _isVisible = false;
    }
  }
}

class _LoadingOverlay extends StatefulWidget {
  final String? message;
  const _LoadingOverlay({Key? key, this.message}) : super(key: key);

  @override
  _LoadingOverlayState createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  Future<void> dismiss() async => await _controller.reverse();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.1), // Ultra light dim
        body: Stack(
          children: [
            // The Backdrop Blur replaces the "Card"
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLoader(),
                  if (widget.message != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      widget.message!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return SizedBox(
      width: 48,
      height: 48,
      child: ShaderMask(
        shaderCallback: (rect) => const SweepGradient(
          startAngle: 0,
          endAngle: 3.14 * 2,
          colors: [Colors.white, Color(0xFF1B6EF3)], // Smooth transition
          stops: [0.3, 1.0],
        ).createShader(rect),
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}

// Extension for easy access
extension GlobalLoadingExtension on BuildContext {
  void showLoading({String? message}) =>
      GlobalLoading.show(this, message: message);
  Future<void> hideLoading() => GlobalLoading.hide();
}
