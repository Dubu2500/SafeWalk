import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../services/account_repository.dart';
import 'account_provider.dart';

class DeviceTokenProvider extends ChangeNotifier {
  DeviceTokenProvider(
    this.account, {
    AccountRepository? repository,
    Future<String?> Function()? getToken,
    Stream<String>? onTokenRefresh,
    Stream<RemoteMessage>? onMessage,
    this.onForegroundMessage,
  }) : _repository = repository ?? account.repository,
       // ignore: deprecated_member_use
       _getToken = getToken ?? FirebaseMessaging.instance.getToken {
    account.addListener(_accountChanged);
    try {
      _refreshSubscription =
          // ignore: deprecated_member_use
          (onTokenRefresh ?? FirebaseMessaging.instance.onTokenRefresh).listen(
            _save,
            onError: (Object error) =>
                debugPrint('Token refresh error: $error'),
          );
      _messageSubscription = (onMessage ?? FirebaseMessaging.onMessage).listen(
        _foregroundMessage,
        onError: (Object error) => debugPrint('onMessage error: $error'),
      );
    } catch (error) {
      debugPrint('Notificaciones no disponibles: $error');
    }
    _accountChanged();
  }

  final void Function(String title, String body)? onForegroundMessage;
  StreamSubscription<RemoteMessage>? _messageSubscription;

  final AccountProvider account;
  final AccountRepository _repository;
  final Future<String?> Function() _getToken;
  StreamSubscription<String>? _refreshSubscription;
  String? _savedForUid;
  String? token;
  bool _disposed = false;

  String? get _uid => account.profile == null ? null : account.auth.user?.uid;

  void _accountChanged() {
    final uid = _uid;
    if (uid == null) {
      _savedForUid = null;
      return;
    }
    if (uid == _savedForUid) return;
    _savedForUid = uid;
    unawaited(_loadAndSave());
  }

  Future<void> _loadAndSave() async {
    try {
      final current = await _getToken();
      if (current != null) await _save(current);
    } catch (error) {
      debugPrint('No se pudo obtener el token del dispositivo: $error');
    }
  }

  void _foregroundMessage(RemoteMessage message) {
    debugPrint('Notificación recibida: ${message.messageId}');
    if (!account.notifications) return;
    final notification = message.notification;
    if (notification == null) return;
    onForegroundMessage?.call(
      notification.title ?? '',
      notification.body ?? '',
    );
  }

  Future<void> _save(String newToken) async {
    final uid = _uid;
    token = newToken;
    if (!_disposed) notifyListeners();
    if (uid == null) return;
    try {
      await _repository.saveDeviceToken(uid, newToken);
      debugPrint('Token del dispositivo guardado para $uid');
    } catch (error) {
      debugPrint('No se pudo guardar el token del dispositivo: $error');
      if (uid == _savedForUid) _savedForUid = null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    account.removeListener(_accountChanged);
    unawaited(_refreshSubscription?.cancel());
    unawaited(_messageSubscription?.cancel());
    super.dispose();
  }
}
