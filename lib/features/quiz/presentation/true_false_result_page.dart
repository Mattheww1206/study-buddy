import 'package:flutter/material.dart';
import 'package:studybuddy/features/deck/model/deck_model.dart';

class TrueFalseResultPage extends StatefulWidget {
  const TrueFalseResultPage({super.key});

  @override
  State<TrueFalseResultPage> createState() => _TrueFalseResultPageState();
}

class _TrueFalseResultPageState extends State<TrueFalseResultPage> {
  int _correctCount = 0;
  int _totalCards = 0;
  List<Map<String, String>> wrongAnswers = [];
  late Deck deck;
  bool _initialized = false;
  String timeUsed = '';
  
  // BAGONG VARIABLE: Flag para sa streak logic
  bool _isFirstQuizToday = false;

  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFFFF7D00);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _correctCount = args['correctCount'] as int;
    _totalCards = args['totalCards'] as int;
    wrongAnswers = List<Map<String, String>>.from(args['wrongAnswers'] as List);
    deck = args['deck'] as Deck;
    timeUsed = args['timeUsed'] as String;
    
    // Kunin ang streak flag mula sa quiz page arguments
    _isFirstQuizToday = args['isFirstQuizToday'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final double accuracy = _totalCards > 0 ? _correctCount / _totalCards : 0.0;
    final int accuracyPercent = (accuracy * 100).toInt();
    final bool isExcellent = accuracy >= 0.75;

    return Scaffold(
      backgroundColor: dominantColor,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "QUIZ COMPLETE!",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2),
                ),
                const SizedBox(height: 15),
                // Circle Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                    color: const Color(0xFF867FE0),
                  ),
                  child: Icon(isExcellent ? 
                    Icons.emoji_events : Icons.sentiment_satisfied_alt,
                    size: 50, color: Colors.white),
                ),
                Text(
                  "$accuracyPercent%",
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isExcellent ? 'Excellent Work! 🎉' : "Keep Practicing! 💪",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                // Quiz Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "📊 True or False • $_totalCards Questions • ${deck.subject}",
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 0),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Total Score Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8E5FF)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_correctCount/$_totalCards',
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: dominantColor),
                          ),
                          const Text(
                            'TOTAL SCORE',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.black38,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Accuracy Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F7FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8E5FF)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bar_chart_rounded,
                                      color: dominantColor, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Accuracy',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ],
                              ),
                              Text('$accuracyPercent%',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: dominantColor)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: accuracy,
                              minHeight: 10,
                              backgroundColor: const Color(0xFFE0E0E0),
                              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time and streak
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F7FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE8E5FF)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    color: Colors.black26, size: 22),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(timeUsed,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      const Text('TIME USED',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.black38,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // CONDITIONAL RENDERING: Streak Logic
                        Expanded(
                          child: _isFirstQuizToday
                          ? Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F7FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE8E5FF)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.local_fire_department,
                                      color: accentColor, size: 22),
                                  const SizedBox(width: 8),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("+1 day",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      Text('STREAK',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.black38,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE8E5FF)),
                              ),
                              child: const Center(
                                child: Text(
                                  "Daily Streak\nFinished",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10, 
                                    color: Colors.black26, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Review Answers Button
                    if (wrongAnswers.isNotEmpty) ...[
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          'tf_review',
                          arguments: {
                            'wrongAnswers': wrongAnswers,
                            'deck': deck,
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: secondaryColor,
                          minimumSize: const Size(double.infinity, 58),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fact_check, size: 20),
                            SizedBox(width: 10),
                            Text('Review Wrong Answers',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Back to Home Button 
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          'home',
                          (route) => false,
                          arguments: 2,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: dominantColor,
                        minimumSize: const Size(double.infinity, 58),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Back to Study',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}