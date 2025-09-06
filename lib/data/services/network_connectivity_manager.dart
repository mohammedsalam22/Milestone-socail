import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkConnectivityManager {
  static bool _isOnline = false;
  static final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  static StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;
  static StreamSubscription<InternetConnectionStatus>? _connectionSubscription;

  static Stream<bool> get connectivityStream => _connectivityController.stream;
  static bool get isOnline => _isOnline;

  static Future<void> initialize() async {
    // Check initial connectivity
    _isOnline = await _checkConnectivity();
    _connectivityController.add(_isOnline);

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      final wasOnline = _isOnline;
      _isOnline =
          results.isNotEmpty && results.first != ConnectivityResult.none;

      // Only trigger callback if status actually changed
      if (wasOnline != _isOnline) {
        _connectivityController.add(_isOnline);

        if (!wasOnline && _isOnline) {
          // Network reconnected - trigger sync
          await _onNetworkReconnected();
        }
      }
    });

    // Also listen to internet connection checker for more accurate status
    _connectionSubscription = InternetConnectionChecker.instance.onStatusChange
        .listen((InternetConnectionStatus status) async {
          final wasOnline = _isOnline;
          _isOnline = status == InternetConnectionStatus.connected;

          // Only trigger callback if status actually changed
          if (wasOnline != _isOnline) {
            _connectivityController.add(_isOnline);

            if (!wasOnline && _isOnline) {
              // Network reconnected - trigger sync
              await _onNetworkReconnected();
            }
          }
        });
  }

  static Future<bool> checkOnline() async {
    return await _checkConnectivity();
  }

  static Future<bool> _checkConnectivity() async {
    try {
      // First check if we have any connectivity
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.isEmpty ||
          connectivityResults.first == ConnectivityResult.none) {
        return false;
      }

      // Then check if we actually have internet access
      final hasConnection =
          await InternetConnectionChecker.instance.hasConnection;
      return hasConnection;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  static Future<void> _onNetworkReconnected() async {
    print('🌐 Network reconnected - triggering sync...');
    // This will be handled by the AttendanceSyncService
    // We'll inject the callback when initializing the service
  }

  // Set callback for network reconnection
  static Function()? _onReconnectedCallback;
  static void setOnReconnectedCallback(Function() callback) {
    _onReconnectedCallback = callback;
  }

  // Dispose resources
  static Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _connectivityController.close();
  }

  // Force check connectivity (useful for manual checks)
  static Future<bool> forceCheck() async {
    _isOnline = await _checkConnectivity();
    _connectivityController.add(_isOnline);
    return _isOnline;
  }

  // Get current connectivity type
  static Future<String> getConnectivityType() async {
    final results = await Connectivity().checkConnectivity();
    if (results.isEmpty) return 'None';

    final result = results.first;
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'None';
    }
  }
}
