import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InactivityWatcher extends StatefulWidget {
  final Duration timeout;
  final Duration warningBefore;
  final VoidCallback onTimeout;
  final Widget child;

  const InactivityWatcher({
    super.key,
    required this.timeout,
    this.warningBefore = const Duration(seconds: 30),
    required this.onTimeout,
    required this.child,
  });

  @override
  State<InactivityWatcher> createState() => _InactivityWatcherState();
}

class _InactivityWatcherState extends State<InactivityWatcher> {
  Timer? _timer;
  Timer? _warningTimer;
  bool _warningShown = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _restart();
  }

  bool _onKey(KeyEvent event) {
    _restart();
    return false;
  }

  void _restart() {
    _timer?.cancel();
    _warningTimer?.cancel();

    if (_warningShown) {
      _warningShown = false;
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    }

    final warningTime = widget.timeout - widget.warningBefore;
    _warningTimer = Timer(warningTime, _showWarning);
    _timer = Timer(widget.timeout, widget.onTimeout);
  }

  void _showWarning() {
    if (!mounted || _warningShown) return;
    _warningShown = true;

    // Динамический текст с количеством секунд
    final seconds = widget.warningBefore.inSeconds;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Сессия завершится через $seconds секунд из-за неактивности',
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        duration: widget.warningBefore,
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _timer?.cancel();
    _warningTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restart(),
      onPointerMove: (_) => _restart(),
      onPointerSignal: (_) => _restart(),
      child: widget.child,
    );
  }
}