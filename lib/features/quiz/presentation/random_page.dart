import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';
import 'package:studybuddy/features/flashcards/model/flashcard_model.dart';
import 'package:studybuddy/features/quiz/service/quiz_service.dart';
import 'package:studybuddy/features/results/model/study_result.dart';
import 'package:studybuddy/features/results/service/result_service.dart';

void main() {
  runApp(const MaterialApp(
    home: RandomPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class RandomPage extends StatefulWidget {
  const RandomPage({super.key});

  @override
  State<RandomPage> createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
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
  String? _selectedOption;
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

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
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
      final quizData = await _quizService.generateRandomQuiz(
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

  void _onNextTapped() {
    final currentData = _quizData[_currentIndex];
    final type = currentData['type'] as String;
    bool isCorrect = false;

    if (type == 'multiple_choice') {
      if (_selectedOption == null) return;
      isCorrect = _selectedOption == currentData['correctAnswer'];
      _quizData[_currentIndex]['selectedAnswer'] = _selectedOption;
    } else if (type == 'identification') {
      final userAnswer = _answerController.text.trim();
      if (userAnswer.isEmpty) return;
      final correct =
          (currentData['correctAnswer'] as String).trim().toLowerCase();
      isCorrect = userAnswer.toLowerCase() == correct;
      _quizData[_currentIndex]['userAnswer'] = userAnswer;
      _quizData[_currentIndex]['isCorrect'] = isCorrect;
    } else if (type == 'true_false') {
      if (_selectedOption == null) return;
      isCorrect = _selectedOption == currentData['correctAnswer'];
      _quizData[_currentIndex]['selectedAnswer'] = _selectedOption;
    }

    if (isCorrect) _correctCount++;

    if (_currentIndex >= _quizData.length - 1) {
      _finishQuiz();
    } else {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
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

    // build wrong answers across all types
    final wrongAnswers = <Map<String, String>>[];
    for (final data in _quizData) {
      final type = data['type'] as String;
      if (type == 'multiple_choice') {
        final selected = data['selectedAnswer'] as String?;
        final correct = data['correctAnswer'] as String;
        if (selected != correct) {
          wrongAnswers.add({
            'type': 'multiple_choice',
            'question': (data['flashcard'] as Flashcard).question,
            'correctAnswer': correct,
            'selectedAnswer': selected ?? 'No answer',
          });
        }
      } else if (type == 'identification') {
        final isCorrect = data['isCorrect'] as bool? ?? false;
        if (!isCorrect) {
          wrongAnswers.add({
            'type': 'identification',
            'question': data['question'] as String,
            'correctAnswer': data['correctAnswer'] as String,
            'selectedAnswer': data['userAnswer'] as String? ?? '',
          });
        }
      } else if (type == 'true_false') {
        final selected = data['selectedAnswer'] as String?;
        final correct = data['correctAnswer'] as String;
        if (selected != correct) {
          wrongAnswers.add({
            'type': 'true_false',
            'question': data['statement'] as String,
            'correctAnswer': correct,
            'selectedAnswer': selected ?? 'No answer',
          });
        }
      }
    }

    try {
       _resultService.saveResult(StudyResult(
        resultId: '',
        userId: userId,
        deckId: _deck.deckId,
        deckTitle: _deck.title,
        mode: 'random',
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
      'ran_result',
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

  bool get _canProceed {
    final type = _quizData.isEmpty ? '' : _quizData[_currentIndex]['type'];
    if (type == 'multiple_choice') return _selectedOption != null;
    if (type == 'identification') return _answerController.text.trim().isNotEmpty;
    if (type == 'true_false') return _selectedOption != null;
    return false;
  }
  @override
  Widget build(BuildContext context) {
    // Loading
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
              Text('Generating quiz questions...',
                  style:
                      TextStyle(color: Color(0xFF665FBE), fontSize: 16)),
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
          title: Text(_deck.title,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 80,
                    color: dominantColor.withValues(alpha: 0.4)),
                const SizedBox(height: 20),
                Text('Gemini Unavailable',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: dominantColor)),
                const SizedBox(height: 12),
                Text(
                  'Gemini is currently unavailable or hit the quota limit. Please try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _geminiUnavailable = false;
                      });
                      _loadQuiz();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
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
    final type = currentData['type'] as String;
    final totalQuestions = _quizData.length;
    final progressValue = (_currentIndex + 1) / totalQuestions;
    final progressPercent = (progressValue * 100).toInt();
    final isLastQuestion = _currentIndex >= totalQuestions - 1;

    /*print('currentData keys: ${currentData.keys}');
    print('currentData values: ${currentData.values}');
    print('type: ${currentData['type']}');
    print('flashcard: ${currentData['flashcard']}');
    print('statement: ${currentData['statement']}');
    print('question: ${currentData['question']}');*/

    final questionText = type == 'true_false'
        ? (currentData['statement'] ?? '') as String
        : type == 'multiple_choice' 
            ? (currentData['flashcard'] as Flashcard).question
            : (currentData['question'] ?? '') as String;

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
        child: Column(
          children: [
            // Status
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
            
           // Question 
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 160, // Pareho sa ibang pages para consistent ang "Study Buddy" app mo
                maxHeight: 220, // Sakto lang para hindi ma-overlap ang input fields
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4), // Para mas mukhang "lifted" ang card
                  )
                ],
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    questionText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: dominantColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Answer 
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: type == 'multiple_choice'
                    ? _buildMCOptions(currentData)
                    : type == 'identification'
                        ? _buildIdentificationInput()
                        : _buildTFOptions(),
              ),
            ),

            // Next / Submit Button
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
                  onPressed: _canProceed ? _onNextTapped : null,
                  child: Text(
                    isLastQuestion ? 'Submit' : 'Next Question',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMCOptions(Map<String, dynamic> currentData) {
    final choices = currentData['choices'] as List<dynamic>;
    return Column(
      children: List.generate(choices.length, (index) {
        final choice = choices[index].toString();
        final isSelected = _selectedOption == choice;
        final letter = String.fromCharCode(65 + index);
        return GestureDetector(
          onTap: () => setState(() => _selectedOption = choice),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? dominantColor : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      isSelected ? dominantColor : secondaryColor,
                  child: Text(letter,
                      style: TextStyle(
                          color:
                              isSelected ? Colors.white : dominantColor,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(choice,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIdentificationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Answer:',
            style: TextStyle(
                color: dominantColor,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: _answerController,
          autofocus: true,
          onChanged: (_) => setState(() {}), // rebuild to update _canProceed
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
    );
  }

  Widget _buildTFOptions() {
    return Column(
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
                color: isSelected ? dominantColor : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      isSelected ? dominantColor : secondaryColor,
                  child: Icon(
                    option == 'True' ? Icons.check : Icons.close,
                    color: isSelected ? Colors.white : dominantColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 20),
                Text(option.toUpperCase(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? dominantColor
                            : Colors.black87)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}