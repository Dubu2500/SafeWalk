import 'dart:async';

/// Foreground journey reminders; cancel when the journey ends or preferences change.
class JourneyReminder {
  JourneyReminder(
    this.onReminder, {
    this.interval = const Duration(minutes: 10),
  });
  final void Function() onReminder;
  final Duration interval;
  Timer? _timer;
  bool _enabled = false;
  void setEnabled(bool enabled) {
    if (_enabled == enabled) return;
    _enabled = enabled;
    _timer?.cancel();
    if (enabled) _timer = Timer.periodic(interval, (_) => onReminder());
  }

  void dispose() {
    _timer?.cancel();
    _enabled = false;
  }
}
