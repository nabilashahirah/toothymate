import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// PROFILE MODEL
// ==========================================
class ChildProfile {
  final String id;
  final String name;
  final Color avatarColor;
  final DateTime createdAt;

  ChildProfile({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.createdAt,
  });

  // Available avatar colors for children
  static const List<Color> avatarColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF3F51B5), // Indigo
  ];

  // Get initials from name
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarColor': avatarColor.toARGB32(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
    id: json['id'],
    name: json['name'],
    avatarColor: Color(json['avatarColor']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

// ==========================================
// PROFILE SERVICE
// ==========================================
class ProfileService {
  static const String _profilesKey = 'child_profiles';
  static const String _activeProfileKey = 'active_profile_id';

  static SharedPreferences? _prefs;
  static ChildProfile? _activeProfile;

  // Initialize the service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get all profiles
  static List<ChildProfile> getAllProfiles() {
    final String? data = _prefs?.getString(_profilesKey);
    if (data == null || data.isEmpty) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => ChildProfile.fromJson(json)).toList();
  }

  // Get active profile
  static ChildProfile? getActiveProfile() {
    if (_activeProfile != null) return _activeProfile;

    final String? activeId = _prefs?.getString(_activeProfileKey);
    if (activeId == null) return null;

    final profiles = getAllProfiles();
    try {
      _activeProfile = profiles.firstWhere((p) => p.id == activeId);
      return _activeProfile;
    } catch (e) {
      return null;
    }
  }

  // Set active profile
  static Future<void> setActiveProfile(ChildProfile profile) async {
    _activeProfile = profile;
    await _prefs?.setString(_activeProfileKey, profile.id);
  }

  // Create a new profile
  static Future<ChildProfile> createProfile(String name, Color avatarColor) async {
    final profiles = getAllProfiles();

    final newProfile = ChildProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatarColor: avatarColor,
      createdAt: DateTime.now(),
    );

    profiles.add(newProfile);
    await _saveProfiles(profiles);

    return newProfile;
  }

  // Update a profile
  static Future<void> updateProfile(ChildProfile updatedProfile) async {
    final profiles = getAllProfiles();
    final index = profiles.indexWhere((p) => p.id == updatedProfile.id);

    if (index != -1) {
      profiles[index] = updatedProfile;
      await _saveProfiles(profiles);

      if (_activeProfile?.id == updatedProfile.id) {
        _activeProfile = updatedProfile;
      }
    }
  }

  // Delete a profile
  static Future<void> deleteProfile(String profileId) async {
    final profiles = getAllProfiles();
    profiles.removeWhere((p) => p.id == profileId);
    await _saveProfiles(profiles);

    // Clear active if deleted
    if (_activeProfile?.id == profileId) {
      _activeProfile = null;
      await _prefs?.remove(_activeProfileKey);
    }

    // Also clear profile-specific data
    await _clearProfileData(profileId);
  }

  // Save profiles to storage
  static Future<void> _saveProfiles(List<ChildProfile> profiles) async {
    final jsonList = profiles.map((p) => p.toJson()).toList();
    await _prefs?.setString(_profilesKey, jsonEncode(jsonList));
  }

  // Clear profile-specific data
  static Future<void> _clearProfileData(String profileId) async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('${profileId}_')) {
        await _prefs?.remove(key);
      }
    }
  }

  // Check if any profiles exist
  static bool hasProfiles() {
    return getAllProfiles().isNotEmpty;
  }

  // Get storage key with profile prefix
  static String getKey(String key) {
    final profile = getActiveProfile();
    if (profile == null) return key;
    return '${profile.id}_$key';
  }

  // Profile-aware SharedPreferences helpers
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(getKey(key), value) ?? false;
  }

  static String? getString(String key) {
    return _prefs?.getString(getKey(key));
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(getKey(key), value) ?? false;
  }

  static int? getInt(String key) {
    return _prefs?.getInt(getKey(key));
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(getKey(key), value) ?? false;
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(getKey(key));
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(getKey(key), value) ?? false;
  }

  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(getKey(key));
  }

  static Future<bool> remove(String key) async {
    return await _prefs?.remove(getKey(key)) ?? false;
  }
}
