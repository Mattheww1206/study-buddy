import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/Achievements/services/achievement_service.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/deck/provider/deck_provider.dart';
import 'package:studybuddy/features/deck/service/deck_service.dart';
import 'package:studybuddy/features/quiz/service/quiz_service.dart';
import 'package:studybuddy/features/results/model/study_result.dart';
import 'package:studybuddy/features/results/service/result_service.dart';

class IdentificationPage extends StatefulWidget {
  const IdentificationPage({super.key});

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  final QuizService _quizService = QuizService();
  final ResultService _resultService = ResultService();
  final DeckService _deckService = DeckService();
  final AchievementService _achievementService = AchievementService();
  final TextEditingController _answerController = TextEditingController();
  late Deck _deck;
  late int _numberOfQuestions;
  late DateTime _startTime;
  int? _timerMinutes;
  List<Map<String, dynamic>> _quizData = [];
  bool _isLoading = true;
  bool _isFinished = false;
  bool _initialized = false;
  int _currentIndex = 0;
  int _correctCount = 0;
  Timer? _timer;
  int _secondsLeft = 0;
  bool _geminiUnavailable = false;

  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFFFF6D00);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _deck = Provider.of<DeckProvider>(context, listen: false).selectedDeck!;
    _numberOfQuestions = args['numberOfQuestions'] as int;
    _timerMinutes = args['timerMinutes'] as int?;

    if (_timerMinutes != null) {
      _secondsLeft = _timerMinutes! * 60;
    }

    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final quizData = await _quizService.generateIdentificationQuiz(
        deckId: _deck.deckId,
        numberOfQuestions: _numberOfQuestions,
      );

      if (!mounted) return;
      setState(() {
        _quizData = quizData;
        _isLoading = false;
      });
      _startTime = DateTime.now();

      if (_timerMinutes != null) _startTimer();
    } catch (e) {
      setState(() => _isLoading = false);
      _geminiUnavailable = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load quiz.')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        _finishQuiz();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerDisplay {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _saveCurrentAnswer() {
    final userAnswer = _answerController.text.trim();
    final currentData = _quizData[_currentIndex];
    final correctAnswer = (currentData['correctAnswer'] as String).trim().toLowerCase();

    _quizData[_currentIndex]['userAnswer'] = userAnswer;
    _quizData[_currentIndex]['isCorrect'] = userAnswer.toLowerCase() == correctAnswer;
  }

  void _onNextTapped() {
    _saveCurrentAnswer();

    if (_currentIndex >= _quizData.length - 1) {
      _finishQuiz();
    } else {
      setState(() {
        _currentIndex++;
        _answerController.text = _quizData[_currentIndex]['userAnswer'] ?? '';
      });
    }
  }

  void _onPrevTapped() {
    if (_currentIndex > 0) {
      _saveCurrentAnswer();
      setState(() {
        _currentIndex--;
        _answerController.text = _quizData[_currentIndex]['userAnswer'] ?? '';
      });
    }
  }

  Future<bool> _handleExitConfirmation() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dominantColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.exit_to_app_rounded, color: dominantColor, size: 44),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quit Quiz?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A6A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to quit? Your current progress will be submitted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dominantColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('SUBMIT & QUIT',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      _finishQuiz();
      return true;
    }
    return false;
  }

  Future<void> _finishQuiz() async {
    if (_isFinished) return;
    _saveCurrentAnswer();
    _isFinished = true;
    _timer?.cancel();

    final elapsed = DateTime.now().difference(_startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final timeUsed = '${minutes}m ${seconds}s';

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;
    final totalCards = _quizData.length;

    _correctCount = _quizData.where((q) => q['isCorrect'] == true).length;

    final wrongAnswers = <Map<String, String>>[];
    for (final data in _quizData) {
      final isCorrect = data['isCorrect'] as bool? ?? false;
      if (!isCorrect) {
        wrongAnswers.add({
          'question': data['question'] as String,
          'correctAnswer': data['correctAnswer'] as String,
          'userAnswer': data['userAnswer'] as String? ?? '',
        });
      }
    }

    try {
      _resultService.saveResult(StudyResult(
        resultId: '',
        userId: userId,
        deckId: _deck.deckId,
        deckTitle: _deck.title,
        mode: 'identification',
        totalCards: totalCards,
        correctCount: _correctCount,
        easyCount: _correctCount,
        againCount: totalCards - _correctCount,
        completedAt: DateTime.now(),
      ));
    } catch (e) {
      print('Error saving result: $e');
    }
    try {
      final results = await _resultService.getUserResults(userId);
      final decks = await _deckService.getUserDecks(userId).first;
      final streak = _resultService.calculateStreak(results);

      final newlyUnlocked = await _achievementService.evaluateAndUnlock(
        userId: userId,
        results: results,
        decks: decks,
        streak: streak,
      );
      if (newlyUnlocked.isNotEmpty && mounted) {
        final name = AchievementService.allAchievement
            .firstWhere((a) => a.achieveId == newlyUnlocked.first).title;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.emoji_events, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Achievement Unlocked: $name!'),
          ]),
          backgroundColor: const Color(0xFF665FBE),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      print('Achievement evaluation error: $e');
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      'iden_result',
      arguments: {
        'correctCount': _correctCount,
        'totalCards': totalCards,
        'wrongAnswers': wrongAnswers,
        'timeUsed': timeUsed,
      },
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: secondaryColor,
        appBar: AppBar(
          backgroundColor: dominantColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => _handleExitConfirmation(),
          ),
          title: Text(_deck.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Generating questions...', style: TextStyle(color: Color(0xFF665FBE), fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_geminiUnavailable) {
       // ... keep your existing geminiUnavailable scaffold here ...
       return Scaffold(/* Existing error UI */);
    }

    if (_quizData.isEmpty) {
      return Scaffold(
        backgroundColor: secondaryColor,
        appBar: AppBar(
          backgroundColor: dominantColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(_deck.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          centerTitle: true,
        ),
        body: const Center(child: Text('No flashcards in this deck.')),
      );
    }

    final currentData = _quizData[_currentIndex];
    final question = currentData['question'] as String;
    final totalQuestions = _quizData.length;
    final progressValue = (_currentIndex + 1) / totalQuestions;
    final progressPercent = (progressValue * 100).toInt();
    final isLastQuestion = _currentIndex >= totalQuestions - 1;

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: dominantColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => _handleExitConfirmation(),
        ),
        title: Text(_deck.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleExitConfirmation();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Status Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question ${_currentIndex + 1}/$totalQuestions',
                                style: TextStyle(fontWeight: FontWeight.bold, color: dominantColor, fontSize: 22),
                              ),
                              Text(
                                '$progressPercent% Completed',
                                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                          if (_timerMinutes != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _secondsLeft < 60 ? Colors.red : dominantColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.timer_outlined, color: _secondsLeft < 60 ? Colors.red : dominantColor, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    _timerDisplay,
                                    style: TextStyle(
                                        color: _secondsLeft < 60 ? Colors.red : dominantColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.white,
                          color: accentColor,
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Question Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 160, maxHeight: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        question,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: dominantColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Answer Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Answer:',
                        style: TextStyle(color: dominantColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _answerController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Type your answer here...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: dominantColor.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: dominantColor, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                  child: Row(
                    children: [
                      if (_currentIndex > 0) ...[
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 60,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFF0F0F0), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: _onPrevTapped,
                              child: Text('Previous',
                                  style: TextStyle(color: dominantColor, fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                      ],
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLastQuestion ? dominantColor : accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            onPressed: _onNextTapped,
                            child: Text(isLastQuestion ? 'Submit' : 'Next',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}