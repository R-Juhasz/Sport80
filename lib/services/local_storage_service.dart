import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/sport80_state.dart';

class LocalStorageService {
  static const _stateKey = 'sport80_state_v2';

  Future<Sport80State> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final rawState = prefs.getString(_stateKey);
    if (rawState == null || rawState.isEmpty) {
      return Sport80State.empty();
    }

    try {
      final json = jsonDecode(rawState) as Map<String, dynamic>;
      return Sport80State.fromJson(json);
    } catch (_) {
      return Sport80State.empty();
    }
  }

  Future<void> saveState(Sport80State state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, state.encode());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stateKey);
  }
}
