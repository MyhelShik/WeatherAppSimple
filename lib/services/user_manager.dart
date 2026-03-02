import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // env пакеты

import 'package:google_sign_in/google_sign_in.dart'; 

import '../models.dart';

class UserManager {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // --- 1. АВТОРИЗАЦИЯ ---
  static Future<String?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        await auth.signInWithPopup(authProvider);
        return null; 
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;
        
        await googleSignIn.initialize(
          // ВСТАВЬ СВОЙ WEB CLIENT ID СЮДА:
            serverClientId: dotenv.env['CLIENT_ID_GOOGLE'] ?? '',
        );
        
        final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
        
        if (googleUser == null) return 'Вход отменен пользователем';

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        
        await auth.signInWithCredential(credential);
        return null;
      }
    } catch (e) {
      return e.toString();
    }
  }

  // --- 2. ЛИМИТЫ ---
  static Future<int> loadLimits(User? user) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (user != null) {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['lastSearchDate'] == today) {
          return data['searchCount'] ?? 0;
        } else {
          await _saveLimitsToCloud(user, 0, today);
          return 0; // Новый день - сброс до нуля
        }
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('lastSearchDate') == today) {
        return prefs.getInt('searchCount') ?? 0;
      }
    }
    return 0; // Если ничего нет, возвращаем 0
  }

  static Future<void> incrementLimit(User? user, int currentSearches) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (user != null) {
      await _saveLimitsToCloud(user, currentSearches, today);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('searchCount', currentSearches);
      await prefs.setString('lastSearchDate', today);
    }
  }

  static Future<void> _saveLimitsToCloud(User user, int count, String date) async {
    await firestore.collection('users').doc(user.uid).set({
      'searchCount': count,
      'lastSearchDate': date,
    }, SetOptions(merge: true));
  }

  // --- 3. СОХРАНЕНИЕ ИЗБРАННОГО ---
  static Future<List<FavoriteItem>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favStr = prefs.getString('fav_list_v2');
    if (favStr != null) {
      List<dynamic> jsonList = jsonDecode(favStr);
      return jsonList.map((json) => FavoriteItem.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> saveFavorites(List<FavoriteItem> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString('fav_list_v2', jsonString);
  }
}