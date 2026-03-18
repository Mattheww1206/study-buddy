import 'package:flutter/material.dart';
import 'package:studybuddy/features/results/model/study_result.dart';
import 'package:studybuddy/features/results/service/result_service.dart';

class ResultProvider extends ChangeNotifier {
  final ResultService _resultService = ResultService();

  List<StudyResult> _results = [];
  bool _isLoading = false;
  String? _error;

  // ─── Getters ─────────────────────────────────────────────────────
  List<StudyResult> get results => _results;
  List<StudyResult> get quizResults =>
      _results.where((r) => r.mode != 'flashcard').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get streak => _resultService.calculateStreak(_results);
  int get totalQuizTaken => quizResults.length;
  int get todayQuizCount => _resultService.todayQuizCount(_results);
  int get weekQuizCount => _resultService.weekQuizCount(_results);

  // ─── Load ─────────────────────────────────────────────────────────
  Future<void> loadResults(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _resultService.getUserResults(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Save & Refresh ───────────────────────────────────────────────
  Future<void> saveResult(StudyResult result, String userId) async {
    await _resultService.saveResult(result);
    await loadResults(userId); // refresh so UI updates immediately
  }

  void clearResults() {
    _results = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}