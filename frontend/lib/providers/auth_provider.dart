import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/app_service.dart';

class AuthProvider with ChangeNotifier {
  final AppService _service = ServiceFactory.createService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get mustChangePassword => _currentUser?.mustChangePassword ?? false;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final user = _service.currentUser;
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _service.getUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final success = await _service.signInWithEmail(email, password);
    if (success) {
      final user = _service.currentUser;
      if (user != null) {
        _currentUser = await _service.getUser(user.id);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    _isLoading = true;
    notifyListeners();

    final success = await _service.signUpWithEmail(email, password, name, role);
    if (success) {
      final user = _service.currentUser;
      if (user != null) {
        _currentUser = user;
        await _service.saveUser(user);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _service.signOut();
    _currentUser = null;
    notifyListeners();
  }
}

