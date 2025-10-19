import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity checker utility
class NetworkChecker {
  static final Connectivity _connectivity = Connectivity();
  static StreamController<bool>? _networkStatusController;
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  /// Get current network status
  static Future<bool> isConnected() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return connectivityResults.any((result) => 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet
      );
    } catch (e) {
      return false;
    }
  }
  
  /// Get network status stream
  static Stream<bool> get networkStatusStream {
    _networkStatusController ??= StreamController<bool>.broadcast();
    return _networkStatusController!.stream;
  }
  
  /// Start listening to network changes
  static void startListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected = results.any((result) => 
          result == ConnectivityResult.mobile || 
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet
        );
        _networkStatusController?.add(isConnected);
      },
    );
  }
  
  /// Stop listening to network changes
  static void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _networkStatusController?.close();
    _networkStatusController = null;
  }
  
  /// Get detailed connectivity info
  static Future<Map<String, dynamic>> getConnectivityInfo() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final isConnected = connectivityResults.any((result) => 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet
      );
      
      return {
        'isConnected': isConnected,
        'connectionTypes': connectivityResults.map((e) => e.toString()).toList(),
        'hasWifi': connectivityResults.contains(ConnectivityResult.wifi),
        'hasMobile': connectivityResults.contains(ConnectivityResult.mobile),
        'hasEthernet': connectivityResults.contains(ConnectivityResult.ethernet),
      };
    } catch (e) {
      return {
        'isConnected': false,
        'connectionTypes': [],
        'hasWifi': false,
        'hasMobile': false,
        'hasEthernet': false,
        'error': e.toString(),
      };
    }
  }
}

/// Riverpod provider for network status
final networkStatusProvider = StreamProvider<bool>((ref) {
  return NetworkChecker.networkStatusStream;
});

/// Riverpod provider for connectivity info
final connectivityInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await NetworkChecker.getConnectivityInfo();
});

/// Riverpod provider for current connection status
final isConnectedProvider = FutureProvider<bool>((ref) async {
  return await NetworkChecker.isConnected();
});
