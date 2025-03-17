// data/datasources/local/local_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodkie/core/constants/app_constants.dart';
import 'package:foodkie/data/models/user_model.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  // Initialize the local storage
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User-related storage methods
  static Future<bool> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.userIdKey, user.id);
    await _prefs.setString(AppConstants.userRoleKey, user.role.name);
    await _prefs.setString(AppConstants.userEmailKey, user.email);
    await _prefs.setString(AppConstants.userNameKey, user.name);

    // Save the full user object as JSON
    final userJson = json.encode(user.toJson());
    return await _prefs.setString('user_data', userJson);
  }

  static UserModel? getUser() {
    final userJson = _prefs.getString('user_data');
    if (userJson == null) return null;

    try {
      return UserModel.fromJson(json.decode(userJson));
    } catch (e) {
      return null;
    }
  }

  static String? getUserId() {
    return _prefs.getString(AppConstants.userIdKey);
  }

  static String? getUserRole() {
    return _prefs.getString(AppConstants.userRoleKey);
  }

  static String? getUserEmail() {
    return _prefs.getString(AppConstants.userEmailKey);
  }

  static String? getUserName() {
    return _prefs.getString(AppConstants.userNameKey);
  }

  static Future<bool> saveAuthToken(String token) async {
    return await _prefs.setString(AppConstants.authTokenKey, token);
  }

  static String? getAuthToken() {
    return _prefs.getString(AppConstants.authTokenKey);
  }

  static Future<bool> clearUserData() async {
    await _prefs.remove(AppConstants.userIdKey);
    await _prefs.remove(AppConstants.userRoleKey);
    await _prefs.remove(AppConstants.userEmailKey);
    await _prefs.remove(AppConstants.userNameKey);
    await _prefs.remove(AppConstants.authTokenKey);
    return await _prefs.remove('user_data');
  }

  // Remember me functionality
  static Future<bool> saveRememberMe(bool value) async {
    return await _prefs.setBool(AppConstants.rememberMeKey, value);
  }

  static bool getRememberMe() {
    return _prefs.getBool(AppConstants.rememberMeKey) ?? false;
  }

  // App theme preferences
  static Future<bool> saveDarkMode(bool isDarkMode) async {
    return await _prefs.setBool(AppConstants.isDarkModeKey, isDarkMode);
  }

  static bool getDarkMode() {
    return _prefs.getBool(AppConstants.isDarkModeKey) ?? false;
  }

  // General storage methods
  static Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<bool> saveDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<bool> saveStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  static Future<bool> saveObject(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, json.encode(value));
  }

  static Map<String, dynamic>? getObject(String key) {
    final objString = _prefs.getString(key);
    if (objString == null) return null;

    try {
      return json.decode(objString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  static Future<bool> clear() async {
    return await _prefs.clear();
  }

  static bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}