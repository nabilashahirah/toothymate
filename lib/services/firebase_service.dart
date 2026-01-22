import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase service for ToothyMate user data storage
/// Uses Anonymous Auth - no login required from user
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userId;
  bool _isInitialized = false;

  String? get userId => _userId;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase and sign in anonymously
  Future<void> init() async {
    try {
      print('🔥 FIREBASE: Starting anonymous sign in...');
      // Sign in anonymously (creates unique user ID)
      UserCredential userCredential = await _auth.signInAnonymously();
      _userId = userCredential.user?.uid;
      _isInitialized = true;
      print('🔥 FIREBASE: SUCCESS! User ID: $_userId');
    } catch (e) {
      print('🔥 FIREBASE ERROR: $e');
      _isInitialized = false;
    }
  }

  /// Get reference to user document
  DocumentReference? get _userDoc {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId);
  }

  // ==================== USER DATA ====================

  /// Save user data to Firestore
  Future<void> saveUserData({
    required String userName,
    required int xp,
    required int streak,
    required bool morningBrush,
    required bool nightBrush,
    required String lastBrushDate,
    required List<String> completedLessons,
  }) async {
    print('🔥 FIREBASE: Attempting to save data...');
    print('🔥 FIREBASE: userId = $_userId');

    if (_userDoc == null) {
      print('🔥 FIREBASE: ERROR - userDoc is null! Not saving.');
      return;
    }

    try {
      await _userDoc!.set({
        'userName': userName,
        'xp': xp,
        'streak': streak,
        'morningBrush': morningBrush,
        'nightBrush': nightBrush,
        'lastBrushDate': lastBrushDate,
        'completedLessons': completedLessons,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('🔥 FIREBASE: SUCCESS - Data saved!');
    } catch (e) {
      print('🔥 FIREBASE: ERROR saving data: $e');
    }
  }

  /// Load user data from Firestore
  Future<Map<String, dynamic>?> loadUserData() async {
    if (_userDoc == null) return null;

    try {
      DocumentSnapshot doc = await _userDoc!.get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
    return null;
  }

  /// Update specific field
  Future<void> updateField(String field, dynamic value) async {
    if (_userDoc == null) return;

    try {
      await _userDoc!.update({
        field: value,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating field $field: $e');
    }
  }

  // ==================== CHAT HISTORY ====================

  /// Save chat message
  Future<void> saveChatMessage(String sender, String text) async {
    if (_userDoc == null) return;

    try {
      await _userDoc!.collection('chatHistory').add({
        'sender': sender,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving chat message: $e');
    }
  }

  /// Load chat history
  Future<List<Map<String, String>>> loadChatHistory() async {
    if (_userDoc == null) return [];

    try {
      QuerySnapshot snapshot = await _userDoc!
          .collection('chatHistory')
          .orderBy('timestamp', descending: false)
          .limit(100) // Limit to last 100 messages
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'sender': data['sender']?.toString() ?? '',
          'text': data['text']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
    return [];
  }

  /// Clear chat history
  Future<void> clearChatHistory() async {
    if (_userDoc == null) return;

    try {
      final batch = _firestore.batch();
      final snapshots = await _userDoc!.collection('chatHistory').get();
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('Chat history cleared');
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
    }
  }

  // ==================== SYNC WITH LOCAL ====================

  /// Sync Firebase data with SharedPreferences (for offline support)
  Future<void> syncToLocal() async {
    final data = await loadUserData();
    if (data == null) return;

    final prefs = await SharedPreferences.getInstance();

    if (data['userName'] != null) {
      await prefs.setString('user_name', data['userName']);
    }
    if (data['xp'] != null) {
      await prefs.setInt('user_xp', data['xp']);
    }
    if (data['streak'] != null) {
      await prefs.setInt('streak_count', data['streak']);
    }
    if (data['morningBrush'] != null) {
      await prefs.setBool('morning_brush', data['morningBrush']);
    }
    if (data['nightBrush'] != null) {
      await prefs.setBool('night_brush', data['nightBrush']);
    }
    if (data['lastBrushDate'] != null) {
      await prefs.setString('last_brush_date', data['lastBrushDate']);
    }
    if (data['completedLessons'] != null) {
      await prefs.setStringList(
        'completed_lessons',
        List<String>.from(data['completedLessons']),
      );
    }

    debugPrint('Firebase data synced to local storage');
  }

  /// Upload local data to Firebase (for first-time sync)
  Future<void> syncFromLocal() async {
    final prefs = await SharedPreferences.getInstance();

    await saveUserData(
      userName: prefs.getString('user_name') ?? 'Hero',
      xp: prefs.getInt('user_xp') ?? 0,
      streak: prefs.getInt('streak_count') ?? 0,
      morningBrush: prefs.getBool('morning_brush') ?? false,
      nightBrush: prefs.getBool('night_brush') ?? false,
      lastBrushDate: prefs.getString('last_brush_date') ?? '',
      completedLessons: prefs.getStringList('completed_lessons') ?? [],
    );

    debugPrint('Local data synced to Firebase');
  }
}
