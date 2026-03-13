import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  Timer? _timer;

  ConnectivityProvider() {
    _init();
  }

  void _init() {
    // check every 10 seconds
    checkRealInternet();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      checkRealInternet();
    });
  }

  Future<bool> checkRealInternet() async {
    try {
      await FirebaseFirestore.instance
          .collection('_connectivity_check')
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 4));
      
      if (!_isOnline) {
        _isOnline = true;
        print('Connectivity changed: Online');
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (_isOnline) {
        _isOnline = false;
        print('Connectivity changed: Offline');
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> recheck() async => checkRealInternet();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}