import 'dart:async';

/// Emits when a 401 Unauthorized response is received.
/// AuthCubit listens to this to clear state and emit AuthUnauthenticated.
class UnauthorizedNotifier {
  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;

  void notifyUnauthorized() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  void dispose() {
    _controller.close();
  }
}
