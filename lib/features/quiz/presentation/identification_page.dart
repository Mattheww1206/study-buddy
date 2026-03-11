import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _deck = args['deck'] as Deck;
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

  void _onNextTapped() {
    final userAnswer = _answerController.text.trim();
    final currentData = _quizData[_currentIndex];
    final correctAnswer =
        (currentData['correctAnswer'] as String).trim().toLowerCase();
    final isCorrect = userAnswer.toLowerCase() == correctAnswer;

    _quizData[_currentIndex]['userAnswer'] = userAnswer;
    _quizData[_currentIndex]['isCorrect'] = isCorrect;

    if (isCorrect) _correctCount++;

    if (_currentIndex >= _quizData.length - 1) {
      _finishQuiz();
    } else {
      setState(() {
        _currentIndex++;
        _answerController.clear();
      });
    }
  }

  Future<void> _finishQuiz() async {
    if (_isFinished) return;
    _isFinished = true;
    _timer?.cancel();

    final elapsed = DateTime.now().difference(_startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final timeUsed = '${minutes}m ${seconds}s';

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user!.userId;
    final totalCards = _quizData.length;

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
      await _resultService.saveResult(StudyResult(
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

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      'iden_result',
      arguments: {
        'correctCount': _correctCount,
        'totalCards': totalCards,
        'wrongAnswers': wrongAnswers,
        'deck': _deck,
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

  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFFFF6D00);

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
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(_deck.title,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Generating questions...',
                  style: TextStyle(color: Color(0xFF665FBE), fontSize: 16)),
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
          title: Text(
            _deck.title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 80, color: dominantColor.withValues(alpha: 0.4)),
                const SizedBox(height: 20),
                Text(
                  'AI Unavailable',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: dominantColor),
                ),
                const SizedBox(height: 12),
                Text(
                  'The AI service is currently unavailable or rate limited. Please try again in a moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 👈 retry
                      setState(() {
                        _isLoading = true;
                        _geminiUnavailable = false;
                      });
                      _loadQuiz();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dominantColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: dominantColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('Go Back',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: dominantColor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
          title: Text(_deck.title,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_deck.title,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // status section
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: dominantColor,
                                  fontSize: 22),
                            ),
                            Text(
                              '$progressPercent% Completed',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                        if (_timerMinutes != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _secondsLeft < 60
                                    ? Colors.red
                                    : dominantColor.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer_outlined,
                                    color: _secondsLeft < 60
                                        ? Colors.red
                                        : dominantColor,
                                    size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  _timerDisplay,
                                  style: TextStyle(
                                      color: _secondsLeft < 60
                                          ? Colors.red
                                          : dominantColor,
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

              // question card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                    horizontal: 25, vertical: 60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10)
                  ],
                ),
                child: Text(
                  question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: dominantColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 40),

              // answer input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Answer:',
                      style: TextStyle(
                          color: dominantColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _answerController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Type your answer here...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: dominantColor.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: dominantColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // next / submit button
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    onPressed: _onNextTapped,
                    child: Text(
                      isLastQuestion ? 'Submit Answer' : 'Next Question',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}