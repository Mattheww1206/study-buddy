import 'package:flutter/material.dart';
import 'package:studybuddy/features/auth/model/user_model.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;

  void setUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void updateUsername(String newUsername){
    _user?.username = newUsername;
    notifyListeners();
  }
}