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

  void updateUsername(String username) {
  if (_user == null) return;
  _user = AppUser(
    userId: _user!.userId,
    username: username, 
    email: _user!.email,
    provider: _user!.provider,
    photoUrl: _user!.photoUrl,
  );
  notifyListeners();
}

void updatePhotoUrl(String url) {
  if(_user == null) return;
  _user = AppUser(
    userId: _user!.userId, 
    username: _user!.username,
    email: _user!.email,
    provider: _user!.provider,
    photoUrl: url,
  );
  notifyListeners();
}


}