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

class TrueFalsePage extends StatefulWidget {
  const TrueFalsePage({super.key});

  @override
  State<TrueFalsePage> createState() => _TrueFalsePageState();
}

class _TrueFalsePageState extends State<TrueFalsePage> {
  final ResultService _resultService = ResultService();
  final QuizService _quizService = QuizService();
  final AchievementService _achievementService = AchievementService();
  late Deck _deck;
  late DateTime _startTime;
  late int _numberOfQuestions;
  int? _timerMinutes;
  List<Map<String, dynamic>> _quizData = [];
  bool _isLoading = true;
  bool _isFinished = false;
  bool _initialized = false;
  int _currentIndex = 0;
  int _correctCount = 0;
  String? _selectedOption;
  Timer? _timer;
  int _secondsLeft = 0;
  bool _geminiUnavailable = false;

  // NEW BLUE THEME PALETTE
  final Color dominantColor = const Color(0xFF1976D2);   // Solid Primary Blue
  final Color secondaryColor = const Color(0xFFF5F9FF);  // Very Light Blue Background
  final Color accentColor = const Color(0xFF2196F3);     // Action Blue
  final Color actionBlue = const Color(0xFF1976D2);

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
      final quizData = await _quizService.generateTrueFalseQuiz(
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
      setState(() {
        _isLoading = false;
        _geminiUnavailable = true;
      });
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
    if (_selectedOption != null) {
      _quizData[_currentIndex]['selectedAnswer'] = _selectedOption;
    }
  }

  void _onNextTapped() {
    _saveCurrentAnswer();

    if (_currentIndex >= _quizData.length - 1) {
      _finishQuiz();
    } else {
      setState(() {
        _currentIndex++;
        _selectedOption = _quizData[_currentIndex]['selectedAnswer'];
      });
    }
  }

  void _onPrevTapped() {
    if (_currentIndex > 0) {
      _saveCurrentAnswer();
      setState(() {
        _currentIndex--;
        _selectedOption = _quizData[_currentIndex]['selectedAnswer'];
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
                color: dominantColor.withAlpha(25),
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
                color: Color(0xFF1A1A1A),
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
                    child: const Text('CANCEL',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionBlue,
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

    _correctCount = 0;
    final wrongAnswers = <Map<String, String>>[];

    for (var data in _quizData) {
      final selected = data['selectedAnswer'] as String?;
      final correct = data['correctAnswer'] as String;
      final isCorrect = selected == correct;

      data['isCorrect'] = isCorrect;
      if (isCorrect) {
        _correctCount++;
      } else {
        wrongAnswers.add({
          'statement': data['statement'] as String,
          'correctAnswer': correct,
          'selectedAnswer': selected ?? 'No answer',
          'explanation': data['explanation'] as String? ?? '',
        });
      }
    }

    final elapsed = DateTime.now().difference(_startTime);
    final timeUsed = '${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s';
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;
    final totalCards = _quizData.length;

    try {
      _resultService.saveResult(StudyResult(
        resultId: '',
        userId: userId,
        deckId: _deck.deckId,
        deckTitle: _deck.title,
        deckSubject: _deck.subject,
        mode: 'true_false',
        totalCards: totalCards,
        correctCount: _correctCount,
        easyCount: _correctCount,
        againCount: totalCards - _correctCount,
        completedAt: DateTime.now(),
      ));
    } catch (e) {
      debugPrint('Error saving result: $e');
    }

    try {
      final results = await _resultService.getUserResults(userId);
      final decks = Provider.of<DeckProvider>(context, listen: false).decks;
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
          backgroundColor: actionBlue,
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      print('Achievement evaluation error: $e');
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      'tf_result',
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: actionBlue),
              const SizedBox(height: 20),
              Text('Generating questions...',
                  style: TextStyle(color: dominantColor, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_geminiUnavailable) {
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 80, color: dominantColor.withAlpha(100)),
                const SizedBox(height: 20),
                Text('AI Unavailable',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: dominantColor)),
                const SizedBox(height: 12),
                const Text('The AI service is currently unavailable. Please try again later.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _geminiUnavailable = false;
                    });
                    _loadQuiz();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: actionBlue, foregroundColor: Colors.white),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentData = _quizData[_currentIndex];
    final statement = currentData['statement'] as String;
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
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => _handleExitConfirmation(),
        ),
       title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _deck.title,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 20
              
              ),
          
            ),
          ),
        ),
        
            centerTitle:true,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleExitConfirmation();
        },
        child: SafeArea(
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
                            Text('Question ${_currentIndex + 1}/$totalQuestions',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: dominantColor,
                                    fontSize: 22)),
                            Text('$progressPercent% Completed',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                        if (_timerMinutes != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: _secondsLeft < 60
                                      ? Colors.red
                                      : dominantColor.withAlpha(50),
                                  width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer_outlined,
                                    color: _secondsLeft < 60 ? Colors.red : dominantColor, size: 18),
                                const SizedBox(width: 6),
                                Text(_timerDisplay,
                                    style: TextStyle(
                                        color: _secondsLeft < 60 ? Colors.red : dominantColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
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
                          minHeight: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

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
                    BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(statement,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: dominantColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // True / False options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: ['True', 'False'].map((option) {
                    final isSelected = _selectedOption == option;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedOption = option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected ? dominantColor : Colors.transparent, width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isSelected ? dominantColor : secondaryColor,
                              child: Icon(option == 'True' ? Icons.check : Icons.close,
                                  color: isSelected ? Colors.white : dominantColor, size: 20),
                            ),
                            const SizedBox(width: 20),
                            Text(option.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? dominantColor : Colors.black87)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Spacer(),

              // Navigation Row
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
                              side: BorderSide(color: dominantColor.withAlpha(50), width: 1.5),
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: _onPrevTapped,
                            child: Text('Previous',
                                style: TextStyle(
                                    color: dominantColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
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
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedOption != null
                                ? actionBlue
                                : Colors.grey[300],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: _selectedOption != null ? 3 : 0,
                          ),
                          onPressed: _selectedOption != null ? _onNextTapped : null,
                          child: Text(isLastQuestion ? 'Submit' : 'Next',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    );
  }
}