import 'dart:async';
import 'package:flutter/foundation.dart';

/// Listens to multiple streams and notifies when any emits.
/// Used to refresh GoRouter when auth or city state changes.
class MultiStreamRefreshNotifier extends ChangeNotifier {
  late final List<StreamSubscription<dynamic>> _subscriptions;

  MultiStreamRefreshNotifier(List<Stream<dynamic>> streams) {
    _subscriptions = streams
        .map((s) => s.listen((_) => notifyListeners()))
        .toList();
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }
}
