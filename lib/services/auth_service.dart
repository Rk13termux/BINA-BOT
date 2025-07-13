import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import '../utils/logger.dart';

class AuthService extends ChangeNotifier {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _userKey = 'user_data';
  static const String _apiKeyKey = 'binance_api_key';
  static const String _apiSecretKey = 'binance_api_secret';
  static const String _sessionKey = 'session_token';

  User? _currentUser;
  bool _isAuthenticated = false;
  final AppLogger _logger = AppLogger();

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize authentication service
  Future<void> initialize() async {
    try {
      await _loadUserData();
      await _validateSession();
    } catch (e) {
      _logger.error('Failed to initialize auth service: $e');
    }
  }

  // User authentication methods
  Future<bool> login(String email, String password) async {
    try {
      // In a real app, this would make an API call to your backend
      // For demo purposes, we'll simulate authentication

      // In a real implementation, you would validate the hashed password
      // final hashedPassword = _hashPassword(password);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Create demo user (in real app, this would come from your backend)
      _currentUser = User(
        id: '1',
        email: email,
        displayName: email.split('@')[0],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      _isAuthenticated = true;

      // Store user data securely
      await _saveUserData();
      await _createSession();

      _logger.info('User logged in successfully: ${_currentUser!.email}');
      return true;
    } catch (e) {
      _logger.error('Login failed: $e');
      return false;
    }
  }

  // Guest login for demo purposes
  Future<void> loginAsGuest() async {
    try {
      _currentUser = User(
        id: 'guest',
        email: 'guest@invictustraderpro.com',
        displayName: 'Guest User',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      _isAuthenticated = true;
      await _saveUserData();

      _logger.info('Guest login successful');
    } catch (e) {
      _logger.error('Guest login failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _currentUser = null;
      _isAuthenticated = false;

      // Clear stored data
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _sessionKey);

      _logger.info('User logged out');
    } catch (e) {
      _logger.error('Logout failed: $e');
    }
  }

  // Binance API credentials management
  Future<bool> saveApiCredentials(String apiKey, String apiSecret) async {
    try {
      await _storage.write(key: _apiKeyKey, value: apiKey);
      await _storage.write(key: _apiSecretKey, value: apiSecret);

      _logger.info('API credentials saved');
      return true;
    } catch (e) {
      _logger.error('Failed to save API credentials: $e');
      return false;
    }
  }

  Future<Map<String, String?>> getApiCredentials() async {
    try {
      final apiKey = await _storage.read(key: _apiKeyKey);
      final apiSecret = await _storage.read(key: _apiSecretKey);

      return {
        'apiKey': apiKey,
        'apiSecret': apiSecret,
      };
    } catch (e) {
      _logger.error('Failed to get API credentials: $e');
      return {'apiKey': null, 'apiSecret': null};
    }
  }

  Future<void> clearApiCredentials() async {
    try {
      await _storage.delete(key: _apiKeyKey);
      await _storage.delete(key: _apiSecretKey);

      _logger.info('API credentials cleared');
    } catch (e) {
      _logger.error('Failed to clear API credentials: $e');
    }
  }

  // Check if user has valid API credentials
  Future<bool> hasApiCredentials() async {
    final credentials = await getApiCredentials();
    return credentials['apiKey'] != null && credentials['apiSecret'] != null;
  }

  // Update subscription - All users now have full access
  Future<bool> updateSubscription(String newTier) async {
    try {
      if (_currentUser == null) return false;

      // No need to update subscription tier since all features are free
      // Just save current user data
      await _saveUserData();

      _logger.info('All features are available for free - no subscription needed');
      return true;
    } catch (e) {
      _logger.error('Failed to update subscription: $e');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({String? displayName, String? email}) async {
    try {
      if (_currentUser == null) return false;

      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        email: email ?? _currentUser!.email,
      );

      await _saveUserData();

      _logger.info('Profile updated');
      return true;
    } catch (e) {
      _logger.error('Failed to update profile: $e');
      return false;
    }
  }

  // Private methods
  Future<void> _loadUserData() async {
    try {
      final userData = await _storage.read(key: _userKey);
      if (userData != null) {
        final userMap = json.decode(userData);
        _currentUser = User.fromJson(userMap);
        _isAuthenticated = true;
      }
    } catch (e) {
      _logger.error('Failed to load user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      if (_currentUser != null) {
        final userData = json.encode(_currentUser!.toJson());
        await _storage.write(key: _userKey, value: userData);
      }
    } catch (e) {
      _logger.error('Failed to save user data: $e');
    }
  }

  Future<void> _createSession() async {
    try {
      final sessionToken = _generateSessionToken();
      await _storage.write(key: _sessionKey, value: sessionToken);
    } catch (e) {
      _logger.error('Failed to create session: $e');
    }
  }

  Future<void> _validateSession() async {
    try {
      final sessionToken = await _storage.read(key: _sessionKey);
      if (sessionToken == null) {
        _isAuthenticated = false;
        _currentUser = null;
      }
      // In a real app, you would validate the session token with your backend
    } catch (e) {
      _logger.error('Failed to validate session: $e');
      _isAuthenticated = false;
    }
  }

  // Helper method for password hashing (used in production)
  // ignore: unused_element
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString() + _currentUser!.id;
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
