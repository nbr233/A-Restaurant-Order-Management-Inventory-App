import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config.dart';

class AuthProvider extends ChangeNotifier {
  late final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isMockLoggedIn = false;
  String _mockName = 'Admin User';

  String get displayName => AppConfig.useMockData ? _mockName : (_user?.displayName ?? 'User');

  AuthProvider() {
    if (AppConfig.useMockData) {
      return;
    }
    _authService = AuthService();
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => AppConfig.useMockData ? _isMockLoggedIn : _user != null;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    clearError();
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      _isMockLoggedIn = true;
      _setLoading(false);
      return true;
    }
    try {
      await _authService.signInWithEmailPassword(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An error occurred during sign in.';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    clearError();
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      _isMockLoggedIn = true;
      _mockName = name;
      _setLoading(false);
      return true;
    }
    try {
      // In a real app, we would also save the name to Firestore/RealtimeDB
      await _authService.signUpWithEmailPassword(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An error occurred during sign up.';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    if (AppConfig.useMockData) {
      _isMockLoggedIn = false;
      notifyListeners();
      return;
    }
    await _authService.signOut();
  }

  Future<bool> changePassword(String newPassword) async {
    _setLoading(true);
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      _setLoading(false);
      return true;
    }
    try {
      await _authService.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
