import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final _log = Logger();

/// Plays an audible alert when new dispatch orders arrive.
///
/// Injectable for testing — override via the Riverpod provider or pass a mock.
class OrderAlertService {
  OrderAlertService() : _player = AudioPlayer();

  @visibleForTesting
  OrderAlertService.withPlayer(this._player);

  final AudioPlayer _player;

  /// Whether [playNewOrderAlert] has been called at least once.
  ///
  /// Exposed for test verification.
  @visibleForTesting
  int triggerCount = 0;

  /// Play the new-order alert sound. Best-effort — failures are logged but
  /// never thrown.
  Future<void> playNewOrderAlert() async {
    triggerCount++;
    try {
      _log.d('OrderAlertService: playing new order alert');
      await _player.play(
        AssetSource('sounds/new_order.wav'),
        mode: PlayerMode.lowLatency,
      );
    } on Exception catch (e, st) {
      _log.e(
        'OrderAlertService: playback failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Release player resources.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
