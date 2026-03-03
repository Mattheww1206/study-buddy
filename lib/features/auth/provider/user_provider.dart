import 'package:flutter/material.dart';
import 'package:studybuddy/features/auth/model/user_model.dart';

class UserProvider extends ChangeNotifier {
  appUser? _user;

  appUser? get user => _user;

  void setUser(appUser user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}