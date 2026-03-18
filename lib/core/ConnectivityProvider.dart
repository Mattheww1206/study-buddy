import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/features/recentlyDeleted/service/recently_deleted_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final RecentlyDeletedService _recentlyDeletedService = RecentlyDeletedService();
  final Connectivity _connectivity = Connectivity();

  ConnectivityProvider() {
    _init();
  }

  void _init() {
    // 1. Check initial state immediately
    checkRealInternet();

    // 2. Listen for hardware changes (Wi-Fi on/off, Cell on/off)
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        // Hardware says we are disconnected
        _updateState(false);
      } else {
        // Hardware is back, now verify if we actually have data flow
        checkRealInternet();
      }
    });
  }

  /// Verifies actual data flow. 
  /// We use a DNS lookup first (free/fast) and fallback to Firestore if needed.
  Future<bool> checkRealInternet() async {
    try {
      // Step A: Fast DNS Lookup (No cost)
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateState(true);
        return true;
      }
      _updateState(false);
      return false;
    } catch (_) {
      // Step B: If DNS fails, double check with Firestore 
      // (Useful if the user is behind a proxy/firewall)
      return await _verifyWithFirestore();
    }
  }

  Future<bool> _verifyWithFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('_connectivity_check')
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 4));

      _updateState(true);
      return true;
    } catch (e) {
      _updateState(false);
      return false;
    }
  }

  void _updateState(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      print('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
      notifyListeners();

      if (_isOnline) {
        _syncPendingDeletions();
      }
    }
  }

  Future<void> _syncPendingDeletions() async {
    try {
      await _recentlyDeletedService.syncPendingDeletions();
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}